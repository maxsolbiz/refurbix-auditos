-- RefurbiX AuditOS Development Seed Data
-- ==============================================================================

-- Insert default organization
INSERT INTO organizations (id, name, slug, domain, settings) VALUES 
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    'MaxSolbiz Demo Organization', 
    'maxsolbiz-demo',
    'maxsolbiz.com',
    '{
        "branding": {
            "logo": "/images/maxsolbiz-logo.png",
            "primary_color": "#667eea",
            "secondary_color": "#764ba2"
        },
        "audit_settings": {
            "default_timeout": 300,
            "require_photos": true,
            "auto_grade": true
        }
    }'
);

-- Insert default users
INSERT INTO users (id, organization_id, email, password_hash, first_name, last_name, role, permissions, email_verified) VALUES 
-- Super Admin (password: admin123)
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d480',
    'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    'admin@maxsolbiz.com',
    '$2b$10$rQZ9qr1ZzQZ9qr1ZzQZ9qOJ9qr1ZzQZ9qr1ZzQZ9qr1ZzQZ9qr1Z.',
    'System',
    'Administrator',
    'super_admin',
    '["*"]',
    true
),
-- Org Admin (password: orgadmin123)
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d481',
    'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    'manager@maxsolbiz.com',
    '$2b$10$rQZ9qr1ZzQZ9qr1ZzQZ9qOJ9qr1ZzQZ9qr1ZzQZ9qr1ZzQZ9qr1Z.',
    'John',
    'Manager',
    'org_admin',
    '["org:manage", "user:manage", "workflow:manage", "report:full_access"]',
    true
),
-- Technician (password: tech123)
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d482',
    'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    'technician@maxsolbiz.com',
    '$2b$10$rQZ9qr1ZzQZ9qr1ZzQZ9qOJ9qr1ZzQZ9qr1ZzQZ9qr1ZzQZ9qr1Z.',
    'Jane',
    'Smith',
    'technician',
    '["audit:create", "audit:read", "device:read", "device:update"]',
    true
),
-- Viewer (password: view123)
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d483',
    'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    'viewer@maxsolbiz.com',
    '$2b$10$rQZ9qr1ZzQZ9qr1ZzQZ9qOJ9qr1ZzQZ9qr1ZzQZ9qr1ZzQZ9qr1Z.',
    'Bob',
    'Viewer',
    'viewer',
    '["audit:read", "device:read", "report:read"]',
    true
);

-- Insert default workflow
INSERT INTO workflows (id, organization_id, name, description, steps, is_default, created_by) VALUES 
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d484',
    'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    'Standard Hardware Audit',
    'Complete hardware audit workflow for refurbished devices',
    '[
        {
            "id": 1,
            "name": "Initial Registration",
            "description": "Register device and create initial record",
            "type": "registration",
            "required": true,
            "timeout": 60
        },
        {
            "id": 2,
            "name": "Hardware Detection",
            "description": "Detect all hardware components",
            "type": "hardware_scan",
            "required": true,
            "timeout": 120
        },
        {
            "id": 3,
            "name": "CPU Testing",
            "description": "Test CPU performance and thermal",
            "type": "cpu_test",
            "required": true,
            "timeout": 180
        },
        {
            "id": 4,
            "name": "Memory Testing",
            "description": "Test RAM for errors and performance",
            "type": "memory_test",
            "required": true,
            "timeout": 300
        },
        {
            "id": 5,
            "name": "Storage Testing",
            "description": "Test storage devices and SMART data",
            "type": "storage_test",
            "required": true,
            "timeout": 600
        },
        {
            "id": 6,
            "name": "Network Testing",
            "description": "Test network adapters",
            "type": "network_test",
            "required": false,
            "timeout": 60
        },
        {
            "id": 7,
            "name": "Final Report",
            "description": "Generate final audit report",
            "type": "report_generation",
            "required": true,
            "timeout": 30
        }
    ]',
    true,
    'f47ac10b-58cc-4372-a567-0e02b2c3d480'
);

-- Insert sample device lot
INSERT INTO device_lots (id, organization_id, name, description, expected_count, workflow_id, created_by) VALUES 
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d485',
    'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    'December 2024 Batch',
    'Mixed desktop and laptop devices from office closure',
    50,
    'f47ac10b-58cc-4372-a567-0e02b2c3d484',
    'f47ac10b-58cc-4372-a567-0e02b2c3d481'
);

-- Insert sample devices
INSERT INTO devices (id, organization_id, lot_id, serial_number, mac_address, manufacturer, model, device_type, cpu_model, ram_gb, storage_gb, status) VALUES 
-- Desktop devices
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d486',
    'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    'f47ac10b-58cc-4372-a567-0e02b2c3d485',
    'DL001234567',
    '00:11:22:33:44:55',
    'Dell',
    'OptiPlex 3070',
    'desktop',
    'Intel Core i5-9500',
    8,
    256,
    'pending'
),
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d487',
    'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    'f47ac10b-58cc-4372-a567-0e02b2c3d485',
    'HP987654321',
    '00:11:22:33:44:56',
    'HP',
    'EliteDesk 800 G5',
    'desktop',
    'Intel Core i7-9700',
    16,
    512,
    'pending'
),
-- Laptop devices
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d488',
    'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    'f47ac10b-58cc-4372-a567-0e02b2c3d485',
    'LN123456789',
    '00:11:22:33:44:57',
    'Lenovo',
    'ThinkPad T480',
    'laptop',
    'Intel Core i5-8250U',
    8,
    256,
    'in_audit'
),
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d489',
    'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    'f47ac10b-58cc-4372-a567-0e02b2c3d485',
    'DL789012345',
    '00:11:22:33:44:58',
    'Dell',
    'Latitude 7420',
    'laptop',
    'Intel Core i7-1185G7',
    16,
    512,
    'passed'
);

-- Insert sample audit (completed)
INSERT INTO audits (id, device_id, user_id, workflow_id, audit_type, status, progress, completed_at, duration_seconds, quality_score, results) VALUES 
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d48a',
    'f47ac10b-58cc-4372-a567-0e02b2c3d489',
    'f47ac10b-58cc-4372-a567-0e02b2c3d482',
    'f47ac10b-58cc-4372-a567-0e02b2c3d484',
    'initial',
    'completed',
    100,
    NOW() - INTERVAL '2 hours',
    240,
    87,
    '{
        "summary": {
            "total_tests": 15,
            "passed": 13,
            "failed": 0,
            "warnings": 2
        },
        "performance": {
            "cpu_score": 85,
            "memory_score": 90,
            "storage_score": 88,
            "overall_score": 87
        },
        "issues": [
            "Battery capacity at 78% of original",
            "Wi-Fi driver needs update"
        ],
        "recommendations": [
            "Consider battery replacement for premium grade",
            "Update wireless drivers before deployment"
        ]
    }'
);

-- Insert sample hardware components for the audit
INSERT INTO hardware_components (audit_id, component_type, component_name, component_data, test_results, status, performance_score) VALUES 
-- CPU
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d48a',
    'cpu',
    'Intel Core i7-1185G7',
    '{
        "cores": 4,
        "threads": 8,
        "base_clock": "3.0 GHz",
        "boost_clock": "4.8 GHz",
        "architecture": "Tiger Lake",
        "tdp": "28W"
    }',
    '{
        "temperature_idle": 35,
        "temperature_load": 68,
        "benchmark_score": 2450,
        "stress_test_passed": true
    }',
    'pass',
    85
),
-- Memory
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d48a',
    'memory',
    '16GB DDR4-3200',
    '{
        "total_gb": 16,
        "type": "DDR4",
        "speed": "3200 MHz",
        "slots_used": 2,
        "slots_total": 2
    }',
    '{
        "errors_found": 0,
        "test_duration": 300,
        "throughput_mbps": 25600
    }',
    'pass',
    90
),
-- Storage
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d48a',
    'storage',
    '512GB NVMe SSD',
    '{
        "capacity_gb": 512,
        "type": "NVMe SSD",
        "model": "Samsung PM981",
        "interface": "PCIe 3.0 x4"
    }',
    '{
        "smart_status": "PASSED",
        "health_percentage": 95,
        "read_speed_mbps": 3200,
        "write_speed_mbps": 1800,
        "power_on_hours": 2840
    }',
    'pass',
    88
),
-- Battery (laptop specific)
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d48a',
    'battery',
    '57Wh Lithium-ion',
    '{
        "design_capacity": "57 Wh",
        "current_capacity": "44.5 Wh",
        "technology": "Li-ion",
        "cycle_count": 342
    }',
    '{
        "health_percentage": 78,
        "charge_rate_ok": true,
        "discharge_rate_ok": true
    }',
    'warning',
    78
);

-- Insert sample OS image
INSERT INTO os_images (id, organization_id, name, version, os_type, description, is_active, created_by) VALUES 
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d48b',
    'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    'Windows 11 Pro Corporate',
    '22H2',
    'windows_11',
    'Windows 11 Professional with corporate applications and updates',
    true,
    'f47ac10b-58cc-4372-a567-0e02b2c3d481'
);

-- Insert sample notifications
INSERT INTO notifications (organization_id, user_id, type, title, message, data) VALUES 
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    'f47ac10b-58cc-4372-a567-0e02b2c3d482',
    'audit_completed',
    'Audit Completed Successfully',
    'Device DL789012345 (Dell Latitude 7420) has completed initial audit with score 87%',
    '{
        "device_id": "f47ac10b-58cc-4372-a567-0e02b2c3d489",
        "audit_id": "f47ac10b-58cc-4372-a567-0e02b2c3d48a",
        "score": 87
    }'
),
(
    'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    'f47ac10b-58cc-4372-a567-0e02b2c3d481',
    'system_alert',
    'New Lot Created',
    'Device lot "December 2024 Batch" has been created with 50 expected devices',
    '{
        "lot_id": "f47ac10b-58cc-4372-a567-0e02b2c3d485",
        "expected_count": 50
    }'
);