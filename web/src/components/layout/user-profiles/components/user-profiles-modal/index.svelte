<script>
  import Modal from 'src/components/ui/modal/base/index.svelte';
  import { T } from 'src/lib/locale';
  import Tabs from 'src/components/ui/tabs';
  import PasswordField from 'src/components/ui/float-input/custom-password-field/index.svelte';
  import InputField from 'src/components/ui/float-input/text-input';
  import Error from 'src/components/ui/error';
  import Form from 'src/lib/form/form';
  import { themes } from './helper';
  import { ButtonPressed } from 'src/components/ui/button/types';
  import { SettingsStore } from 'src/store/settings';
  import { SObject } from 'src/lib/sobject';
  import { validation } from './validation';
  import Snackbar from 'src/components/ui/snackbar/index.svelte';
  import { catchError } from 'rxjs/operators';
  import { of } from 'rxjs';
  import { StringUtil } from 'src/lib/string-util';
  import FloatSelect from 'src/components/ui/float-input/select';
  import { Authentication } from 'src/lib/authentication';
  import { LanguageStore } from 'src/features/system/language/store';
  import { LoginInfo } from 'src/store/login-info';
  import { BaseUrl } from 'src/lib/constants';

  const { languages$ } = LanguageStore;

  const { theme$ } = LoginInfo;

  let containerWidth = '300px';

  const defaultWidth = 800;
  const defaultHeight = 400;

  let modalRef, excelGridRef, languageDropdownRef;
  let ExcelGridComponent;
  let height = '200px';

  const tabTitleKeys = ['GENERAL', 'THEME', 'ACCOUNT'];
  let activeTab = 'GENERAL';
  const menuPath = 'sys/user-profiles-modal';

  let currentTheme;
  let snackbarRef;

  const columns = [
    {
      type: 'hidden',
      name: 'key',
    },
    {
      type: 'text',
      title: T('SYS.LABEL.AVAILABLE_THEME'),
      name: 'theme',
      width: 120,
      readOnly: true,
    },
    {
      type: 'color',
      title: T('SYS.LABEL.PREVIEW'),
      name: 'preview',
      width: 120,
      readOnly: true,
      render: 'square',
    },
    {
      type: 'radio',
      title: T('SYS.LABEL.CHOOSE'),
      name: 'choose',
      width: 80,
    },
  ];

  LanguageStore.findLanguages().subscribe();

  const resetForm = () => {
    return new Form({
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
    });
  };
  let form = resetForm();

  let mappedThemes = SObject.clone(themes);

  const onResize = (event) => {
    containerWidth = event.detail.width;
    // calcHeight();
    //
  };

  const calcHeight = () => {
    const h = modalRef.getHeight().replace('px', '');
    height = `${h - 100}px`;
  };

  export const show = () => {
    form = resetForm();
    calcHeight();
    return new Promise((resolve, reject) => {
      import('src/components/ui/excel-grid/index.svelte').then((res) => {
        ExcelGridComponent = res.default;
        resolve(modalRef.show());
      });
      // @ts-ignore
    }).then((buttonPressed) => {
      if (buttonPressed === ButtonPressed.ok) {
        theme$.next(currentTheme);
        saveTheme();
      } else {
        applyTheme($theme$);
        mappedThemes = SObject.clone(themes);
      }
    });
  };

  $: if ($theme$) {
    applyTheme($theme$);
  }

  const applyTheme = (theme) => {
    const body = document.querySelector('body');
    body.className = '';
    body.style = '';
    // add new theme
    if (theme !== 'ivory') {
      body.classList.add(theme);
    }
  };

  const onThemeChanged = (event) => {
    const selectedRow = +event.detail.y;
    currentTheme = themes[selectedRow].key;
    applyTheme(currentTheme);
  };

  const saveTheme = () => {
    SettingsStore.saveUserSettings({
      keys: ['theme'],
      values: [currentTheme],
    });
  };

  const saveAccountSettings = () => {
    return new Promise((resolve, reject) => {
      // client validation
      if (StringUtil.isEmpty(form.currentPassword) && StringUtil.isEmpty(form.newPassword)) {
        resolve(true);
        return;
      }
      form.errors.errors = form.recordErrors(validation(form));
      if (form.errors.any()) {
        if (activeTab !== 'ACCOUNT') {
          snackbarRef.show(T('SYS.MSG.ACCOUNT_SETTING_ERROR'));
          activeTab = 'ACCOUNT';
        }
        resolve(false);
      } else {
        form
          .put(BaseUrl.SYSTEM, 'auth/change-pw')
          .pipe(catchError((error) => of(error)))
          .subscribe(
            (res) => {
              if (res.response && res.response.data) {
                if (res.response.data.field) {
                  form.errors.errors = form.recordErrors(res.response.data);
                } else {
                  snackbarRef.showUnknownError(res.response.data.message || res.response.data);
                }
                resolve(false);
              } else {
                if (res.data.message === 1) {
                  snackbarRef.show(T('SYS.MSG.CHANGE_PASSWORD_SUCCESS'));
                }

                form = resetForm();
                resolve(true);
              }
            },
            (error) => reject(false),
          );
      }
    });
  };

  $: {
    const theme = $theme$;
    if (theme) {
      mappedThemes.map((it) => {
        it.choose = theme === it.key;
        if (it.choose) {
          currentTheme = theme;
        }

        return it;
      });
    }
  }

  const onApplyLanguage = (event) => {
    window.location.reload();
  };
</script>

<Snackbar bind:this={snackbarRef} />
<Modal
  beforeOK={saveAccountSettings}
  {defaultWidth}
  {defaultHeight}
  on:containerResize={onResize}
  {menuPath}
  contentClass="full-modal-content"
  fontIcon="<i class='fa fa-user-circle'></i>"
  title={T('SYS.LABEL.USER_PROFILES')}
  id="userProfilesModalId"
  bind:this={modalRef}>

  <Tabs titleKeys={tabTitleKeys} bind:activeTab>
    {#if activeTab === 'GENERAL'}
      <FloatSelect
        on:change={onApplyLanguage}
        autoLoad={true}
        saveState={true}
        {menuPath}
        bind:this={languageDropdownRef}
        id="localeResourceUsedLanguageSelectId"
        data={$languages$ ? $languages$.map((it) => {
              it.id = it.locale;
              return it;
            }) : $languages$}
        placeholder={T('SYS.LABEL.LANGUAGE')} />
    {:else if activeTab === 'ACCOUNT'}
      <form class="form" on:keydown={(event) => form.errors.clear(event.target.name)}>
        <div>
          <InputField readonly={true} value={Authentication.getUsername()} placeholder={T('SYS.LABEL.USERNAME')} />
        </div>

        <div>
          <PasswordField
            name="currentPassword"
            bind:value={form.currentPassword}
            placeholder={T('SYS.LABEL.CURRENT_PASSWORD')} />
          <Error {form} field="currentPassword" />
        </div>

        <div>
          <PasswordField name="newPassword" bind:value={form.newPassword} placeholder={T('SYS.LABEL.NEW_PASSWORD')} />
          <Error {form} field="newPassword" />
        </div>

        <div>
          <PasswordField
            name="confirmPassword"
            bind:value={form.confirmPassword}
            placeholder={T('SYS.LABEL.CONFIRM_PASSWORD')} />
          <Error {form} field="confirmPassword" />
        </div>
      </form>
    {:else if activeTab === 'THEME'}
      <div style="margin-top: 10px;">
        <svelte:component
          this={ExcelGridComponent}
          {height}
          {menuPath}
          bind:this={excelGridRef}
          id={'gridUserProfilesModal'}
          {columns}
          data={mappedThemes}
          {containerWidth}
          on:changed={onThemeChanged}
          fullWidth={true}>
          <span slot="label" class="label">{T('SYS.LABEL.CONTROL_LIST')}:</span>
        </svelte:component>
      </div>
    {/if}
  </Tabs>
</Modal>
