import { RxHttp } from 'src/lib/rx-http';
import { BaseUrl } from 'src/lib/constants';
import { LoginInfo } from 'src/store/login-info';
import { grpcAuthClient } from 'src/lib/grpc';
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

  static logoutAPI = () => {
    const req = new empty.Empty();
    return grpcAuthClient.logoutHandler(req, defaultHeader); 
  };

  static setHeader = (token) => {
    axios.defaults.headers['Content-Type'] = 'application/json';
    axios.defaults.headers['Authorization'] = `Bearer ${token}`;

    defaultHeader = {
      authorization: 'Bearer ' + token,
    }
  };

  static refreshAPI = (refreshToken) => {
    console.log('Refreshing token!', refreshToken);
    const req = new RefreshTokenRequest();
    req.setRefreshToken(refreshToken);
    return new Promise((resolve, reject) => {
      grpcAuthClient.refreshTokenHandler(req, defaultHeader).then((res) => {
        res = res.toObject();
        console.log(res);
        if(!res.success) {
          console.log('login again!');
          resolve(res.success)
        } else {
          const { accessToken } = res
          Authentication.setAccessToken(accessToken);
          resolve(accessToken)
        }
      }).catch((err) => {
        reject(err);
      });
    });
   

    // return new Promise((resolve, reject) => {
    //   RxHttp.post({
    //     baseUrl: BaseUrl.SYSTEM,
    //     url: 'auth/refresh-token',
    //     params: { token: refreshToken },
    //   }).subscribe((res) => {
    //     if (!res.data.success) {
    //       console.error('Login again');
    //       resolve(false);
    //     } else {
    //       const { token } = res.data;
    //       Authentication.setAccessToken(token);
    //       resolve(token);
    //     }
    //   });
    // });
  };
}
