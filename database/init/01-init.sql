-- RefurbiX AuditOS Database Initialization
-- ==============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Set timezone
SET timezone = 'UTC';

-- Organizations table (Multi-tenancy)
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    domain VARCHAR(255),
    settings JSONB DEFAULT '{}',
    subscription_plan VARCHAR(50) DEFAULT 'starter',
    subscription_status VARCHAR(50) DEFAULT 'active',
    max_devices INTEGER DEFAULT 100,
    max_users INTEGER DEFAULT 10,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT organizations_slug_format CHECK (slug ~ '^[a-z0-9-]+$')
);

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role VARCHAR(50) NOT NULL DEFAULT 'technician',
    permissions JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    last_login TIMESTAMP WITH TIME ZONE,
    login_count INTEGER DEFAULT 0,
    preferences JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT users_role_check CHECK (role IN ('super_admin', 'org_admin', 'technician', 'viewer')),
    CONSTRAINT users_email_format CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Device lots for batch processing
CREATE TABLE device_lots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    expected_count INTEGER,
    actual_count INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'active',
    workflow_id UUID,
    metadata JSONB DEFAULT '{}',
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT device_lots_status_check CHECK (status IN ('active', 'completed', 'cancelled'))
);

-- Devices table
CREATE TABLE devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    lot_id UUID REFERENCES device_lots(id) ON DELETE SET NULL,
    serial_number VARCHAR(255),
    mac_address VARCHAR(17),
    manufacturer VARCHAR(100),
    model VARCHAR(100),
    device_type VARCHAR(50) DEFAULT 'desktop',
    cpu_model VARCHAR(255),
    ram_gb INTEGER,
    storage_gb INTEGER,
    status VARCHAR(50) DEFAULT 'pending',
    condition_grade VARCHAR(10),
    location VARCHAR(255),
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    first_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_audit TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT devices_type_check CHECK (device_type IN ('desktop', 'laptop', 'server', 'tablet')),
    CONSTRAINT devices_status_check CHECK (status IN ('pending', 'in_audit', 'passed', 'failed', 'in_repair', 'completed', 'disposed')),
    CONSTRAINT devices_grade_check CHECK (condition_grade IN ('A', 'B', 'C', 'D', 'F') OR condition_grade IS NULL),
    CONSTRAINT devices_mac_format CHECK (mac_address ~ '^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2}) OR mac_address IS NULL)
);

-- Workflows table
CREATE TABLE workflows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    steps JSONB NOT NULL DEFAULT '[]',
    is_active BOOLEAN DEFAULT true,
    is_default BOOLEAN DEFAULT false,
    version INTEGER DEFAULT 1,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audits table
CREATE TABLE audits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    workflow_id UUID REFERENCES workflows(id),
    audit_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    progress INTEGER DEFAULT 0,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    duration_seconds INTEGER,
    results JSONB DEFAULT '{}',
    quality_score INTEGER,
    issues_found TEXT[],
    recommendations TEXT[],
    test_summary JSONB DEFAULT '{}',
    environment_info JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT audits_type_check CHECK (audit_type IN ('initial', 'repair_verification', 'final', 'quality_check')),
    CONSTRAINT audits_status_check CHECK (status IN ('pending', 'in_progress', 'completed', 'failed', 'cancelled')),
    CONSTRAINT audits_progress_check CHECK (progress >= 0 AND progress <= 100),
    CONSTRAINT audits_quality_score_check CHECK (quality_score >= 0 AND quality_score <= 100 OR quality_score IS NULL)
);

-- Hardware components detected during audits
CREATE TABLE hardware_components (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    audit_id UUID NOT NULL REFERENCES audits(id) ON DELETE CASCADE,
    component_type VARCHAR(50) NOT NULL,
    component_name VARCHAR(255),
    component_data JSONB NOT NULL DEFAULT '{}',
    test_results JSONB DEFAULT '{}',
    status VARCHAR(50) DEFAULT 'unknown',
    error_messages TEXT[],
    performance_score INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT components_type_check CHECK (component_type IN ('cpu', 'memory', 'storage', 'gpu', 'motherboard', 'battery', 'network', 'audio', 'usb', 'display')),
    CONSTRAINT components_status_check CHECK (status IN ('pass', 'fail', 'warning', 'not_tested', 'unknown')),
    CONSTRAINT components_score_check CHECK (performance_score >= 0 AND performance_score <= 100 OR performance_score IS NULL)
);

-- Workflow executions
CREATE TABLE workflow_executions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_id UUID NOT NULL REFERENCES workflows(id),
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    audit_id UUID REFERENCES audits(id) ON DELETE CASCADE,
    current_step INTEGER DEFAULT 0,
    total_steps INTEGER NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    step_data JSONB DEFAULT '{}',
    error_message TEXT,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT workflow_executions_status_check CHECK (status IN ('pending', 'in_progress', 'completed', 'failed', 'cancelled'))
);

-- OS Images for deployment
CREATE TABLE os_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    version VARCHAR(100),
    os_type VARCHAR(50) NOT NULL,
    architecture VARCHAR(20) DEFAULT 'x64',
    file_path VARCHAR(500),
    file_size BIGINT,
    checksum VARCHAR(128),
    description TEXT,
    metadata JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    download_count INTEGER DEFAULT 0,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT os_images_type_check CHECK (os_type IN ('windows_10', 'windows_11', 'ubuntu', 'debian', 'centos', 'custom')),
    CONSTRAINT os_images_arch_check CHECK (architecture IN ('x64', 'x86', 'arm64'))
);

-- Image deployments
CREATE TABLE image_deployments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    image_id UUID NOT NULL REFERENCES os_images(id),
    user_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'pending',
    progress INTEGER DEFAULT 0,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    error_message TEXT,
    deployment_log TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT deployments_status_check CHECK (status IN ('pending', 'in_progress', 'completed', 'failed', 'cancelled')),
    CONSTRAINT deployments_progress_check CHECK (progress >= 0 AND progress <= 100)
);

-- Notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT false,
    sent_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT notifications_type_check CHECK (type IN ('audit_completed', 'audit_failed', 'device_ready', 'workflow_completed', 'system_alert'))
);

-- Audit logs for security
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id UUID,
    ip_address INET,
    user_agent TEXT,
    result VARCHAR(20) DEFAULT 'success',
    error_message TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT audit_logs_result_check CHECK (result IN ('success', 'failure', 'error'))
);

-- Create indexes for performance
CREATE INDEX idx_organizations_slug ON organizations(slug);
CREATE INDEX idx_users_org_email ON users(organization_id, email);
CREATE INDEX idx_users_org_role ON users(organization_id, role);
CREATE INDEX idx_devices_org_status ON devices(organization_id, status);
CREATE INDEX idx_devices_lot_status ON devices(lot_id, status);
CREATE INDEX idx_devices_serial ON devices(serial_number);
CREATE INDEX idx_devices_mac ON devices(mac_address);
CREATE INDEX idx_audits_device_created ON audits(device_id, created_at DESC);
CREATE INDEX idx_audits_user_created ON audits(user_id, created_at DESC);
CREATE INDEX idx_audits_status_created ON audits(status, created_at DESC);
CREATE INDEX idx_hardware_audit_type ON hardware_components(audit_id, component_type);
CREATE INDEX idx_workflow_executions_device ON workflow_executions(device_id, status);
CREATE INDEX idx_notifications_user_created ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_org_unread ON notifications(organization_id, is_read, created_at DESC);
CREATE INDEX idx_audit_logs_org_created ON audit_logs(organization_id, created_at DESC);
CREATE INDEX idx_audit_logs_user_created ON audit_logs(user_id, created_at DESC);

-- Full-text search indexes
CREATE INDEX idx_devices_search ON devices USING gin(to_tsvector('english', 
    coalesce(serial_number, '') || ' ' || 
    coalesce(manufacturer, '') || ' ' || 
    coalesce(model, '') || ' ' ||
    coalesce(notes, '')
));

CREATE INDEX idx_users_search ON users USING gin(to_tsvector('english',
    coalesce(first_name, '') || ' ' ||
    coalesce(last_name, '') || ' ' ||
    coalesce(email, '')
));

-- Create triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$ language 'plpgsql';

-- Apply triggers to tables
CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON organizations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_device_lots_updated_at BEFORE UPDATE ON device_lots FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_devices_updated_at BEFORE UPDATE ON devices FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_workflows_updated_at BEFORE UPDATE ON workflows FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_audits_updated_at BEFORE UPDATE ON audits FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_os_images_updated_at BEFORE UPDATE ON os_images FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();