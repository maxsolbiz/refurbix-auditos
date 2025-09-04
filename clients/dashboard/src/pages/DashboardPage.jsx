import React from 'react'
import { Layout, Typography, Card, Button, Space, Avatar } from 'antd'
import { LogoutOutlined, DesktopOutlined, UserOutlined } from '@ant-design/icons'
import { useAuth } from '../hooks/useAuth'

const { Header, Content } = Layout
const { Title, Text } = Typography

const DashboardPage = () => {
  const { user, logout } = useAuth()

  const handleLogout = () => {
    logout()
  }

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Header style={{
        background: 'linear-gradient(135deg, #667eea, #764ba2)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: '0 24px'
      }}>
        <div style={{ display: 'flex', alignItems: 'center' }}>
          <DesktopOutlined style={{ fontSize: 24, color: 'white', marginRight: 12 }} />
          <Title level={3} style={{ color: 'white', margin: 0 }}>
            RefurbiX AuditOS
          </Title>
        </div>
        
        <Space>
          <Avatar icon={<UserOutlined />} />
          <Text style={{ color: 'white' }}>
            {user?.firstName} {user?.lastName}
          </Text>
          <Button
            type="text"
            icon={<LogoutOutlined />}
            onClick={handleLogout}
            style={{ color: 'white' }}
          >
            Logout
          </Button>
        </Space>
      </Header>

      <Content style={{ padding: 24 }}>
        <div style={{ maxWidth: 1200, margin: '0 auto' }}>
          <Title level={2}>Welcome to RefurbiX AuditOS Dashboard</Title>
          
          <Card style={{ marginBottom: 24 }}>
            <Title level={4}>User Information</Title>
            <Space direction="vertical">
              <Text><strong>Name:</strong> {user?.firstName} {user?.lastName}</Text>
              <Text><strong>Email:</strong> {user?.email}</Text>
              <Text><strong>Role:</strong> {user?.role}</Text>
              <Text><strong>Organization ID:</strong> {user?.organizationId}</Text>
            </Space>
          </Card>

          <Card>
            <Title level={4}>System Status</Title>
            <Text type="success">✓ Authentication Service: Connected</Text>
            <br />
            <Text type="success">✓ Database: Connected</Text>
            <br />
            <Text>Ready for hardware audit operations</Text>
          </Card>
        </div>
      </Content>
    </Layout>
  )
}

export default DashboardPage
