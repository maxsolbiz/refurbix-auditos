import axios from 'axios'

const API_URL = 'http://localhost:3001'

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

export const authService = {
  login: async (email, password) => {
    const response = await api.post('/v1/auth/login', { email, password })
    return response.data
  },

  logout: async () => {
    try {
      await api.post('/v1/auth/logout')
    } catch (error) {
      console.error('Logout API error:', error)
    }
  },

  getCurrentUser: async () => {
    const response = await api.get('/v1/auth/me')
    return response.data
  },
}

export default api
