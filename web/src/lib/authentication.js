import { RxHttp } from 'src/lib/rx-http';
import { BaseUrl } from 'src/lib/constants';
import { LoginInfo } from 'src/store/login-info';

const axios = require('axios');

export class Authentication {
  static logout = () => {
    Authentication.logoutAPI().then((res) => {
      sessionStorage.clear();
      localStorage.clear();
      window.location.replace('/');
    });
  };

  static getRefreshToken = () => {
    return localStorage.getItem('remember') === 'true'
      ? localStorage.getItem('refreshToken')
      : sessionStorage.getItem('refreshToken');
  };

  static getAccessToken = () => {
    return localStorage.getItem('remember') === 'true'
      ? localStorage.getItem('accessToken')
      : sessionStorage.getItem('accessToken');
  };

  static getUsername = () => {
    return localStorage.getItem('remember') === 'true'
      ? localStorage.getItem('username')
      : sessionStorage.getItem('username');
  };

  static setAccessToken = (token) => {
    if (localStorage.getItem('remember') === 'true') {
      localStorage.setItem('accessToken', token);
    } else {
      sessionStorage.setItem('accessToken', token);
    }
    Authentication.setHeader(token);
  };

  static login = (accessToken, refreshToken, userId) => {
    if (localStorage.getItem('remember') === 'true') {
      localStorage.setItem('accessToken', accessToken);
      localStorage.setItem('refreshToken', refreshToken);
      localStorage.setItem('userId', userId);
    } else {
      sessionStorage.setItem('accessToken', accessToken);
      sessionStorage.setItem('refreshToken', refreshToken);
      sessionStorage.setItem('userId', userId);
    }

    window.location.replace('/');
  };

  static isLoggedIn = () => {
    const token = Authentication.getAccessToken();
    if (token) {
      Authentication.setHeader(token);
    }
    return (token || '').length > 0;
  };

  static loginAPI = (username, password) => {
    return new Promise((resolve, reject) => {
      const auth = {
        username: username,
        password: password,
      };
      RxHttp.post({
        baseUrl: BaseUrl.SYSTEM,
        url: 'auth/login',
        auth,
      }).subscribe(
        (res) => {
          resolve(res.data);
        },
        (err) => {
          reject(err);
        },
      );
    });
  };

  static logoutAPI = () => {
    return new Promise((resolve, reject) => {
      RxHttp.delete({
        baseUrl: BaseUrl.SYSTEM,
        url: `auth/logout?userId=${LoginInfo.getUserId()}`,
      }).subscribe(
        (res) => {
          resolve(res.data);
        },
        (err) => {
          reject(err);
        },
      );
    });
  };

  static setHeader = (token) => {
    axios.defaults.headers['Content-Type'] = 'application/json';
    axios.defaults.headers['Authorization'] = `Bearer ${token}`;
  };

  static refreshAPI = (refreshToken) => {
    console.log('Refreshing token!');
    return new Promise((resolve, reject) => {
      RxHttp.post({
        baseUrl: BaseUrl.SYSTEM,
        url: 'auth/refresh-token',
        params: { token: refreshToken },
      }).subscribe((res) => {
        if (!res.data.success) {
          console.error('Login again');
          resolve(false);
        } else {
          const { token } = res.data;
          Authentication.setAccessToken(token);
          resolve(token);
        }
      });
    });
  };
}
