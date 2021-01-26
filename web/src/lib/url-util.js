import { T } from './locale';
import { StringUtil } from './string-util';
import { AppStore } from 'src/store/app';

export const getMenuPathFromUrl = () => {
  return location.pathname.slice(1).replace('--', '/');
};

export const getMenuPathFromUrlParam = () => {
  const url = new URL(AppStore.urlParam);
  if (url && !url.pathname.includes('logout')) {
    return url.pathname.slice(1).replace('--', '/');
  } else {
    return null;
  }
};

export const getUrlParam = (param) => {
  const url = new URL(AppStore.urlParam);
  if (url) {
    return url.searchParams.get(param);
  } else {
    return null;
  }
};

export const getTargetIdFromUrlParam = () => {
  const url = new URL(AppStore.urlParam);
  if (url) {
    return url.searchParams.get('id');
  } else {
    return null;
  }
};

export const getMenuNameFromPath = (menuPath) => {
  return menuPath.includes('/') ? menuPath.split('/')[menuPath.split('/').length - 1] : menuPath;
};

export const getViewTitleFromMenuPath = (menuPath) => {
  if (StringUtil.isEmpty(menuPath)) {
    return T('SYS.MSG.NO_MENU');
  }
  return T(`SYS.MENU.${StringUtil.replaceAll(getMenuNameFromPath(menuPath).toUpperCase(), '-', '_')}`);
};
