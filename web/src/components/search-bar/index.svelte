<script>
  import { createEventDispatcher } from 'svelte';
  import { StringUtil } from 'src/lib/string-util';
  import { T } from 'src/lib/locale';
  import { of, BehaviorSubject } from 'rxjs';

  import Autocomplete from 'src/components/ui/input/autocomplete';
  import { SearchType } from './types';
  import { extractTemplate } from './helper';
  import Snackbar from 'src/components/ui/snackbar';
  import { Authentication } from 'src/lib/authentication';
  // import { loadMenuAndUserSettings } from 'src/main';

  export let id;
  export let menuPath;

  let placeholder;
  let type = 'search';
  let snackbarRef;
  let inputRef;
  let searchWrapperRef;
  const dispatch = createEventDispatcher();
  const passwordClass = ['suntech-circle', 'suntech-asterisk', 'suntech-x', 'suntech-run', 'suntech-heart'];
  let username;
  let password;
  let remember = false;
  let loginCount = 0;
  let searching$ = new BehaviorSubject(false);

  const recalcPlaceholder = (isLogged) => {
    if (isLogged) {
      placeholder = `${T('SYS.LABEL.WHAT_ARE_YOU_THINKING_ABOUT')}?`;
    } else {
      placeholder = T('SYS.LABEL.LOGIN_OR_SEARCH_HERE');
    }
  };

  recalcPlaceholder(Authentication.isLoggedIn());

  const doLogin = (username, password) => {
    searching$.next(true);
    Authentication.loginAPI(username, password)
      .then((res) => {
        if (res.accessToken) {
          if (remember) {
            localStorage.setItem('username', username);
          } else {
            sessionStorage.setItem('username', username);
          }
          didLogin(res);
          searching$.next(false);
        }
      })
      .catch((err) => {
        searching$.next(false);
        snackbarRef && snackbarRef.show(T(`SYS.MSG.AUTHENTICATION_ERROR`));
      });
  };

  const didLogin = (loginInfo) => {
    loginCount = 0;
    type = 'search';
    setTimeout(() => {
      inputRef.clear();
      inputRef.focus();
    }, 1000);
    localStorage.setItem('remember', remember);
    Authentication.login(loginInfo.accessToken, loginInfo.refreshToken, loginInfo.userId);
  };

  const onLogin = (rawData) => {
    if (loginCount === 1) {
      username = extractTemplate(rawData, '<b>', '</b>');
      placeholder = T('SYS.LABEL.ENTER_YOUR_PASSWORD');
      type = 'password';
      inputRef.clear();
      inputRef.focus();
    } else {
      if (loginCount > 1) {
        password = extractTemplate(rawData, '<b>', '</b>');
        if (!StringUtil.isEmpty(password)) {
          // do login
          doLogin(username, password);
        } else {
          // validate error
          snackbarRef && snackbarRef.show(T('SYS.MSG.PASSWORD_MUST_NOT_BE_BLANK'));
        }
      }
    }
  };

  const onSuggest = (event) => {
    if (Authentication.isLoggedIn()) {
    } else {
      switch (event.detail.id) {
        case SearchType.Login:
          loginCount++;
          if (loginCount === 1) {
            remember = false;
          }
          onLogin(event.detail.name);
          break;
        case SearchType.LoginWithRemember:
          loginCount++;
          remember = true;
          onLogin(event.detail.name);
          break;
        case SearchType.Search:
          break;
        default:
          break;
      }
    }
  };

  const onFocus = (event) => {
    inputRef.removeAttribute('readonly');
  };

  const suggestFunction = (textSearch) => {
    let data;
    if (StringUtil.isEmpty(textSearch)) {
      data = [];
    } else if (!Authentication.isLoggedIn()) {
      data = [
        { id: SearchType.Login, name: `${T('SYS.LABEL.LOGIN_WITH')} <b>${textSearch}</b>` },
        {
          id: SearchType.LoginWithRemember,
          name: `${T('SYS.LABEL.LOGIN_WITH')} <b>${textSearch}</b> (${T('SYS.LABEL.REMEMBER')})`,
        },
        { id: SearchType.Search, name: `${T('SYS.LABEL.SEARCH_WITH')} <b>${textSearch}</b>` },
      ];
    } else {
      // TODO
      data = [{ id: SearchType.Search, name: `${T('SYS.LABEL.SEARCH_AFTER_LOGGED_IN')} <b>${textSearch}</b>` }];
    }
    return of({ data });
  };

  const onShowPopup = () => {
    if (searchWrapperRef) {
      searchWrapperRef.classList.remove('search-bar-wrapper-rounded-border');
      searchWrapperRef.classList.add('search-bar-wrapper-top-rounded-border');
    }
  };

  const onHidePopup = () => {
    if (searchWrapperRef) {
      searchWrapperRef.classList.remove('search-bar-wrapper-top-rounded-border');
      searchWrapperRef.classList.add('search-bar-wrapper-rounded-border');
    }
  };

  const onClickBack = () => {
    recalcPlaceholder(Authentication.isLoggedIn());
    type = 'search';
    inputRef.clear();
    inputRef.focus();
    loginCount = 0;
  };
</script>

<Snackbar bind:this={snackbarRef} />
<div class="search-bar-wrapper search-bar-wrapper-rounded-border" bind:this={searchWrapperRef}>

  <Autocomplete
    useInternalProgress={false}
    {searching$}
    container={searchWrapperRef}
    columns={[{ name: 'name', type: 'html' }]}
    on:showPopup={onShowPopup}
    on:hidePopup={onHidePopup}
    className="rounded-border-auto-dropdown"
    searchFunc={suggestFunction}
    {id}
    {menuPath}
    {type}
    {placeholder}
    bind:this={inputRef}
    on:clickBack={onClickBack}
    on:change={onSuggest} />
</div>
