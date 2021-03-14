<script>
  import Modal from 'src/components/ui/modal/base/index.svelte';
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
  import ImagePicker from 'src/components/ui/image-picker';
  import { StringUtil } from 'src/lib/string-util';
  import FloatSelect from 'src/components/ui/float-input/select';
  import { Authentication } from 'src/lib/authentication';
  import { LanguageStore } from 'src/features/system/language/store';
  import { LoginInfo } from 'src/store/login-info';
  import { ProfileService } from './service';
  import { base64ToUint8Array } from 'src/lib/image';
  import { App } from 'src/lib/constants';

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
  let running = false;

  const columns = [
    {
      type: 'hidden',
      name: 'key',
    },
    {
      type: 'text',
      title: 'SYS.LABEL.AVAILABLE_THEME'.t(),
      name: 'theme',
      width: 120,
      readOnly: true,
    },
    {
      type: 'color',
      title: 'SYS.LABEL.PREVIEW'.t(),
      name: 'preview',
      width: 120,
      readOnly: true,
      render: 'square',
    },
    {
      type: 'radio',
      title: 'SYS.LABEL.CHOOSE'.t(),
      name: 'choose',
      width: 80,
    },
  ];

  LanguageStore.findLanguages();

  const resetForm = () => {
    return new Form({
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
      avatarData: undefined,
      avatarSize: 0,
      avatarType: '',
      avatarExt: '',
    });
  };
  let form = resetForm();
  let beforeForm;
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

  const loadAvatar = () => {
    ProfileService.getOne(LoginInfo.getUserId())
      .then((r) => {
        const res = r.toObject();
        const stream = ProfileService.downloadAvatar(res.iconFilesystemId, res.iconFilepath, res.iconFilename);
        stream.on('data', function(r) {
          const res = r.toObject();
          console.log(res);
        });
      })
      .catch((err) => {
        log.error(err);
      });
  };
  export const show = () => {
    form = resetForm();
    loadAvatar();
    calcHeight();
    return new Promise((resolve, reject) => {
      import('src/components/ui/excel-grid/index.svelte').then((res) => {
        ExcelGridComponent = res.default;
        resolve(modalRef.show());
      });
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
    SettingsStore.saveUserSettings(
      {
        keys: ['theme'],
        values: [currentTheme],
      },
      false,
    );
  };

  const saveAccountSettings = () => {
    return new Promise((resolve, reject) => {
      // client validation
      if (
        StringUtil.isEmpty(form.currentPassword) &&
        StringUtil.isEmpty(form.newPassword) &&
        StringUtil.isEmpty(form.confirmPassword) &&
        beforeForm.avatarData === form.avatarData
      ) {
        resolve(true);
        return;
      } else {
        if (
          !StringUtil.isEmpty(form.currentPassword) ||
          !StringUtil.isEmpty(form.newPassword) ||
          !StringUtil.isEmpty(form.confirmPassword)
        ) {
          form.errors.errors = form.recordErrors(validation(form));
          if (form.errors.any()) {
            if (activeTab !== 'ACCOUNT') {
              snackbarRef.show('SYS.MSG.ACCOUNT_SETTING_ERROR'.t());
              activeTab = 'ACCOUNT';
            }
            resolve(false);
          }
        }

        running = true;
        let changePasswordPromise;
        if (!StringUtil.isEmpty(form.currentPassword)) {
          // change password
          changePasswordPromise = new Promise((resolve, reject) => {
            setTimeout(() => {
              resolve(true);
            }, 5000);
          });
        }

        let updateAvatarPromise;
        if (beforeForm.avatarData !== form.avatarData) {
          updateAvatarPromise = new Promise((resolve, reject) => {
            // update data
            ProfileService.uploadAvatar({
              fileType: form.avatarExt,
              data: base64ToUint8Array(form.avatarData.replace('data:image/jpeg;base64,', '')),
              category: 'PROFILE_AVATAR',
            })
              .then((res) => {
                const uploadRes = res.toObject();
                ProfileService.updateAvatar(uploadRes.fileSystemId, uploadRes.filePath, uploadRes.fileName)
                  .then((_) => {
                    resolve(true);
                  })
                  .catch((err) => {
                    log.error(err);
                    reject(err);
                  });
              })
              .catch((err) => {
                log.error(err);
                reject(err);
              });
          });
        }

        Promise.all([updateAvatarPromise, changePasswordPromise])
          .then(() => {
            resolve(true);
          })
          .catch((err) => {
            log.error(err);
            reject(err);
          })
          .finally(() => {
            running = false;
          });
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

  beforeForm = {
    avatarData: undefined,
  };

  const onImageError = (e) => {
    snackbarRef.show(`${e.detail.t()}. ${'SYS.MSG.MAX_SIZE'.t()}: ${App.SIZE_DETAIL}`);
  };
</script>

<Snackbar bind:this={snackbarRef} />
<Modal
  okRunning={running}
  beforeOK={saveAccountSettings}
  {defaultWidth}
  {defaultHeight}
  on:containerResize={onResize}
  {menuPath}
  contentClass="full-modal-content"
  fontIcon="<i class='fa fa-user-circle'></i>"
  title={'SYS.LABEL.USER_PROFILES'.t()}
  id="userProfilesModalId"
  bind:this={modalRef}>

  <Tabs id="userProfilesTabs" titleKeys={tabTitleKeys} bind:activeTab saveState={true}>
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
        placeholder={'SYS.LABEL.LANGUAGE'.t()} />
    {:else if activeTab === 'ACCOUNT'}
      <form class="form" on:keydown={(event) => form.errors.clear(event.target.name)}>
        <div class="row">
          <div class="col-18">
            <div>
              <InputField readonly={true} value={Authentication.getUsername()} placeholder={'SYS.LABEL.USERNAME'.t()} />
            </div>

            <div>
              <PasswordField
                name="currentPassword"
                bind:value={form.currentPassword}
                placeholder={'SYS.LABEL.CURRENT_PASSWORD'.t()} />
              <Error {form} field="currentPassword" />
            </div>

            <div>
              <PasswordField
                name="newPassword"
                bind:value={form.newPassword}
                placeholder={'SYS.LABEL.NEW_PASSWORD'.t()} />
              <Error {form} field="newPassword" />
            </div>

            <div>
              <PasswordField
                name="confirmPassword"
                bind:value={form.confirmPassword}
                placeholder={'SYS.LABEL.CONFIRM_PASSWORD'.t()} />
              <Error {form} field="confirmPassword" />
            </div>
          </div>

          <div class="col-6">
            <ImagePicker
              on:error={onImageError}
              id="avatar"
              maxSize={App.MAX_AVATAR_SIZE}
              bind:outExt={form.avatarExt}
              bind:outSize={form.avatarSize}
              bind:outType={form.avatarType}
              bind:src={form.avatarData} />
          </div>
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
          <span slot="label" class="label">{'SYS.LABEL.CONTROL_LIST'.t()}:</span>
        </svelte:component>
      </div>
    {/if}
  </Tabs>
</Modal>
