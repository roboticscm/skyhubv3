import { grpcAuthClient, callGRPC } from 'src/lib/grpc';
import { LoginInfo } from 'src/store/login-info';
import { App } from 'src/lib/constants';

const empty = require('google-protobuf/google/protobuf/empty_pb');

import {
  LoginRequest, RefreshTokenRequest, UpdateRemoteAuthenticatedRequest
} from "src/pt/proto/auth/auth_service_pb";

export let defaultHeader = {};


export class Authentication {
  static logout = () => {
    Authentication.logoutAPI().then((res) => {
      sessionStorage.clear();
      localStorage.clear();
      LoginInfo.isLoggedIn$.next(false);
      window.location.replace('/');
    });
  };

  static forceLogout = () => {
    sessionStorage.clear();
    localStorage.clear();
    LoginInfo.isLoggedIn$.next(false);
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

  static isRememberLogin = () => {
    return localStorage.getItem('remember') === 'true';
  };

  static login = (accessToken, refreshToken, userId, username) => {
    if (localStorage.getItem('remember') === 'true') {
      localStorage.setItem('accessToken', accessToken);
      localStorage.setItem('refreshToken', refreshToken);
      localStorage.setItem('userId', userId);
      localStorage.setItem('username', username);
    } else {
      sessionStorage.setItem('accessToken', accessToken);
      sessionStorage.setItem('refreshToken', refreshToken);
      sessionStorage.setItem('userId', userId);
      sessionStorage.setItem('username', username);
    }
    Authentication.setHeader(accessToken);
    window.location.replace('/');
    Authentication.unlockScreen();
  };

  static isLoggedIn = () => {
    const token = Authentication.getAccessToken();
    if (token) {
      Authentication.setHeader(token);
    }
    const result = (token || '').length > 0;
    LoginInfo.isLoggedIn$.next(true);
    return result;
  };


  static loginAPI = (username, password) => {
    const req = new LoginRequest();
    req.setUsername(username);
    req.setPassword(password);
    return grpcAuthClient.loginHandler(req);
  };

  static verifyPassword = (username, password) => {
    const req = new LoginRequest();
    req.setUsername(username);
    req.setPassword(password);
    return grpcAuthClient.verifyPasswordHandler(req, defaultHeader);
  }


  static logoutAPI = () => {
    const req = new empty.Empty();
    return callGRPC(() => {
      return grpcAuthClient.logoutHandler(req, defaultHeader);
    })
  };

  static updateAuthenticated = (id) => {
    const req = new UpdateRemoteAuthenticatedRequest();
    req.setRecordId(id);
    return callGRPC(() => {
      return grpcAuthClient.updateRemoteAuthenticatedHandler(req, defaultHeader);
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

  static isLockScreen = () => {
    return sessionStorage.getItem('PoweredBy') === App.POWERED_BY;
  }

  static lockScreen = () => {
    return sessionStorage.setItem('PoweredBy', App.POWERED_BY);
  }

  static unlockScreen = () => {
    return sessionStorage.removeItem('PoweredBy');
  };
}
