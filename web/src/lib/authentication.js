import { grpcAuthClient, callGRPC } from 'src/lib/grpc';
import { LoginInfo } from 'src/store/login-info';
import { App } from 'src/lib/constants';
import { Browser } from 'src/lib/browser';

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
      Authentication.unlockScreen();
      window.location.replace('/');
    });
  };

  static forceLogout = () => {
    sessionStorage.clear();
    localStorage.clear();
    LoginInfo.isLoggedIn$.next(false);
    Authentication.unlockScreen();
    window.location.replace('/');
  };

  static getRefreshToken = () => {
    const token = localStorage.getItem('remember') === 'true'
      ?  localStorage.getItem('refreshToken')
      : sessionStorage.getItem('refreshToken');

      return Authentication.decodeToken(token);
  };

  static getRawRefreshToken = () => {
    return localStorage.getItem('remember') === 'true'
      ?  localStorage.getItem('refreshToken')
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

  static encodeToken = (token) => {
    if (!token) {
      return token;
    }

    const browserID = Browser.getBrowserID();
    const position = token.length / 2;
    const encodedTotken = token.insertAt(position, browserID);
    
    return encodedTotken;
  }

  static decodeToken = (token) => {
    if (!token) {
      return token;
    }

    const browserID = Browser.getBrowserID();
    const decodedToken = token.replace(browserID, "");
    return decodedToken;
  }

  static encodeRefreshToken = () => {
    const refreshToken = Authentication.getRawRefreshToken();
    if (!refreshToken) {
      return;
    }
    localStorage.setItem('refreshToken', Authentication.encodeToken(refreshToken));
    sessionStorage.setItem('refreshToken', Authentication.encodeToken(refreshToken));
  }

  static decodeRefreshToken = () => {
    const refreshToken = Authentication.getRefreshToken();
    if (!refreshToken) {
      return;
    }
    const browserID = Browser.getBrowserID();

    localStorage.setItem('refreshToken', refreshToken.replaceAll(browserID, ""));
    sessionStorage.setItem('refreshToken', refreshToken.replaceAll(browserID, ""));
  }

  static login = (accessToken, refreshToken, userId, username) => {
    if (Authentication.isLockScreen()) {
      Authentication.logout();
      Authentication.forceLogout();
      return;
    }

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
    LoginInfo.isLoggedIn$.next(result);
    if (Authentication.isLockScreen()) {
      Authentication.logout();
      Authentication.forceLogout();
    }
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
    const refreshToken = Authentication.getRawRefreshToken();
    
    if (!refreshToken) {
      return false;
    }

    return refreshToken.includes(Browser.getBrowserID());
  }

  static lockScreen = () => {
    Authentication.encodeRefreshToken();
  }

  static unlockScreen = () => {
    Authentication.decodeRefreshToken();
  };
}
