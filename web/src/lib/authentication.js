import { grpcAuthClient, callGRPC } from 'src/lib/grpc';
const empty = require('google-protobuf/google/protobuf/empty_pb');

import {
  LoginRequest, RefreshTokenRequest
} from "src/pt/proto/auth/auth_service_pb";


const axios = require('axios');
export let defaultHeader = {};


export class Authentication {
  static logout = () => {
    Authentication.logoutAPI().then((res) => {
      sessionStorage.clear();
      localStorage.clear();
      window.location.replace('/');
    });
  };

  static forceLogout = () => {
    sessionStorage.clear();
    localStorage.clear();
    window.location.replace('/');
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
    const req = new LoginRequest();
    req.setUsername(username);
    req.setPassword(password);
    return grpcAuthClient.loginHandler(req);
  };

  static verifyPassword  = (password) => {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        resolve(true);
      })
    })
  }


  static logoutAPI = () => {
    const req = new empty.Empty();
    return callGRPC(() => {
      return grpcAuthClient.logoutHandler(req, defaultHeader);
    })
  };

  static setHeader = (token) => {
    // axios.defaults.headers['Content-Type'] = 'application/json';
    // axios.defaults.headers['Authorization'] = `Bearer ${token}`;

    defaultHeader = {
      authorization: 'Bearer ' + token,
    }
  };

  static refreshAPI = (refreshToken) => {
    log.info('Refreshing token!');
    const req = new RefreshTokenRequest();
    req.setRefreshToken(refreshToken);
    return callGRPC(() => {
      return new Promise((resolve, reject) => {
        return grpcAuthClient.refreshTokenHandler(req, defaultHeader).then((res) => {
          res = res.toObject();
          if (!res.success) {
            log.info('login again!');
            resolve(res.success)
          } else {
            const { accessToken } = res
            Authentication.setAccessToken(accessToken);
            resolve(accessToken)
          }
        }).catch((err) => {
          reject(err);
        })
      })
    });
  }
}
