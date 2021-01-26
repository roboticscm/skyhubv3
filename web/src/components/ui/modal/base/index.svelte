<script>
  import Button from 'src/components/ui/button/flat-button/index.svelte';
  import { ButtonType, ButtonPressed } from 'src/components/ui/button/types';
  import { ModalType, ModalId } from 'src/components/ui/modal/types';
  import { createModal } from '../use-modal';
  import { debounceTime } from 'src/lib/rx';
  import { onMount, createEventDispatcher, onDestroy } from 'svelte';
  import { StringUtil } from 'src/lib/string-util';
  import { T } from 'src/lib/locale';
  import CustomPasswordInput from 'src/components/ui/input/custom-password-input';
  import TextInput from 'src/components/ui/input/text-input';
  import NumberInput from 'src/components/ui/input/number-input/index.svelte';
  import Form from 'src/lib/form/form';
  import { catchError } from 'rxjs/operators';
  import { of } from 'rxjs';
  import { App } from 'src/lib/constants';
  import { passwordChar } from 'src/components/ui/input/autocomplete/helper';
  import { Browser } from 'src/lib/browser';
  import CloseIcon from 'src/icons/cancel-submit.svelte';
  import Error from 'src/components/ui/error';

  const dispatch = createEventDispatcher();

  export let id;
  export let title = '';
  export let fontIcon = '';
  export let iconData = '';
  export let showControlButton = true;
  export let menuPath;
  export let modalType = ModalType.custom;
  export let showOkButton = true;
  export let showCancelButton = undefined;
  export let showCloseButton = true;
  export let contentClass = 'modal-content';
  export let okButtonTitle = undefined;
  export let cancelButtonTitle = undefined;
  export let defaultHeight = undefined; // in pixel
  export let defaultWidth = undefined; // in pixel
  export let transparent = true;
  export let wrapperClass = '';
  export let beforeOK = undefined;

  let modalWrapperRef;
  let modalRef;
  let passwordRef, inputNumberRef;
  let displayPasswordChar = passwordChar();
  let disabled = false;
  let minValue = 1,
    maxValue = undefined;
  const useModal = createModal(menuPath, defaultWidth, defaultHeight);

  const onResize = (event) => {
    if (modalRef) {
      useModal.state.width = modalRef.style.width;
      useModal.state.height = modalRef.style.height;
      dispatch('containerResize', {
        width: useModal.state.width,
        height: useModal.state.height,
      });
    }
  };

  let resizeObserver;

  if (Browser.getBrowser() !== 'Safari') {
    resizeObserver = new ResizeObserver(debounceTime(100, onResize));
  }

  let form = new Form({
    // username: appStore.user && appStore.user.username,
    // password: '',
    // inputNumber: 1,
  });

  const onMouseUp = (event) => {
    useModal.saveModalState(modalRef);
    dispatch('mouseUp', undefined);
  };

  export const show = (content = '', _disabled = false, min = 0, max = undefined, defaultValue = undefined) => {
    minValue = min;
    maxValue = max;
    form.errors.errors = {};

    disabled = _disabled;
    return new Promise((resolve, reject) => {
      useModal.state.content = content;
      useModal.state.resolve = resolve;
      form.reset();
      form = new Form({
        // username: appStore.user.username,
        // password: '',
        // inputNumber: defaultValue || 1,
      });

      setTimeout(() => {
        passwordRef && passwordRef.focus();
        passwordRef && passwordRef.clear();
      }, 200);

      setTimeout(() => {
        inputNumberRef && inputNumberRef.focus();
      }, 200);

      modalWrapperRef.classList.add('show-modal');
    });
  };

  const onCLose = () => {
    useModal.closeModal(modalWrapperRef, ButtonPressed.close);
  };

  const onCancel = () => {
    useModal.closeModal(modalWrapperRef, ButtonPressed.cancel);
  };

  const onOK = () => {
    if (beforeOK) {
      beforeOK().then((res) => {
        if (res) {
          useModal.closeModal(modalWrapperRef, ButtonPressed.ok);
        }
      });
    } else {
      useModal.closeModal(modalWrapperRef, ButtonPressed.ok);
    }
  };

  onMount(() => {
    useModal.loadSettings(modalRef);
    useModal.dragElement(modalRef);
    resizeObserver && resizeObserver.observe(modalRef);
  });

  onDestroy(() => {
    if (modalRef) {
      resizeObserver && resizeObserver.unobserve(modalRef);
    }
  });

  function loginWithoutGenToken() {
    if (passwordRef) {
      form.password = passwordRef && passwordRef.getPassword();

      form
        .post(`sys/auth/${StringUtil.toSnackCase('loginWithoutGenToken')}`)
        .pipe(
          catchError((error) => {
            return of(error);
          }),
        )
        .subscribe((res) => {
          if (res.response && res.response.data) {
            // error
            form.errors.errors = form.recordErrors(res.response.data);
          } else {
            if (useModal.state.resolve) {
              modalWrapperRef.classList.remove('show-modal');
              useModal.state.resolve(ButtonPressed.OK);
            }
          }
        });
    }

    if (inputNumberRef) {
      onOK();
    }
  }

  export const getHeight = () => {
    return useModal.state.height;
  };

  const preset = (
    _id,
    _title,
    _fontIcon,
    _showCancelButton,
    _okButtonTitle = undefined,
    _cancelButtonTitle = undefined,
  ) => {
    if (StringUtil.isEmpty(id) && !StringUtil.isEmpty(_id)) {
      id = _id;
    }
    if (StringUtil.isEmpty(title) && !StringUtil.isEmpty(_title)) {
      title = T(`SYS.LABEL.${_title}`);
    }
    if (StringUtil.isEmpty(fontIcon) && !StringUtil.isEmpty(_fontIcon)) {
      fontIcon = _fontIcon;
    }

    if (showCancelButton === undefined && _showCancelButton !== undefined) {
      showCancelButton = _showCancelButton;
    }

    if (okButtonTitle === undefined && _okButtonTitle !== undefined) {
      okButtonTitle = T(`SYS.BUTTON.${_okButtonTitle}`);
    }

    if (cancelButtonTitle === undefined && _cancelButtonTitle !== undefined) {
      cancelButtonTitle = T(`SYS.BUTTON.${_cancelButtonTitle}`);
    }
  };

  $: {
    switch (modalType) {
      case ModalType.alert:
        preset(ModalId.alert, 'ALERT', '<i class="fa fa-exclamation-circle"></i>', false);
        break;

      case ModalType.confirm:
        preset(ModalId.confirm, 'CONFIRM', '<i class="fa fa-question-circle"></i>', true, 'YES', 'NO');
        break;

      case ModalType.confirmPassword:
        preset(ModalId.confirmPassword, 'CONFIRM_PASSWORD', '<i class="fa fa-key"></i>', true, 'YES', 'NO');
        break;

      case ModalType.inputText:
        preset(ModalId.inputText, 'INPUT_TEXT', '<i class="fab fa-adn"></i>', true);
        break;

      case ModalType.inputNumber:
        preset(ModalId.inputNumber, 'INPUT_NUMBER', '<i class="fa fa-sort-numeric-up"></i>', true);
        break;

      case ModalType.custom:
        preset(undefined, undefined, undefined, true);
        break;
    }
  }

  export const getInputNumber = () => {
    return form.inputNumber;
  };

  export const raiseError = (err) => {
    form.errors.errors = form.recordErrors({
      inputNumber: err,
    });
  };
</script>

<div bind:this={modalWrapperRef} class="modal-wrapper {wrapperClass} {transparent ? '' : 'modal-wrapper-background'}">
  <form on:submit|preventDefault={loginWithoutGenToken} on:keydown={(e) => form.errors.clear(e.currentTarget.name)}>
    <div bind:this={modalRef} {id} class="modal" on:mouseup={onMouseUp}>
      <div id={id + 'header'} class="modal-header">
        <div class="modal-title">
          <div>
            {#if iconData}
              <img src={iconData} alt="" />
            {:else if fontIcon}
              {@html fontIcon}
            {:else}
              {@html App.DEFAULT_ICON}
            {/if}
            {@html title}
          </div>
        </div>
        <div>
          {#if showCloseButton}
            <div class="modal-header__close" on:click={onCLose}>
              <CloseIcon />
            </div>
          {/if}
        </div>
      </div>

      <div class={contentClass}>
        {@html useModal.state.content}

        {#if modalType === ModalType.ConfirmPassword}
          <div class="row">
            <div style="text-align: right;" class="label col-6">{T('SYS.LABEL.USERNAME')}:</div>
            <div class="col-18">
              <TextInput name="username" bind:value={form.username} disabled={true} />
              {#if form.errors.has('username')}
                <div class="error">{form.errors.get('username')}</div>
              {/if}
            </div>
          </div>

          <div class="row">
            <div style="text-align: right;" class="label col-6">{T('SYS.LABEL.PASSWORD')}:</div>
            <div class="col-18">
              <CustomPasswordInput displayChar={displayPasswordChar} name="password" bind:this={passwordRef} />
              {#if form.errors.has('password')}
                <div class="error">{form.errors.get('password')}</div>
              {/if}
            </div>
          </div>
        {/if}

        {#if modalType === ModalType.inputNumber}
          <NumberInput
            bind:this={inputNumberRef}
            name="inputNumber"
            placeholder={T('SYS.LABEL.INPUT_NUMBER')}
            min={minValue}
            max={maxValue}
            bind:value={form.inputNumber} />
          <Error {form} field="inputNumber" />
        {/if}

        <slot />
      </div>

      {#if showControlButton}
        <div class="modal-controller">
          {#if showOkButton}
            {#if modalType === ModalType.confirmPassword}
              <Button showIcon={true} type="submit" btnType={ButtonType.okModal} title={okButtonTitle} {disabled} />
            {:else}
              <Button showIcon={true} on:click={onOK} btnType={ButtonType.okModal} title={okButtonTitle} {disabled} />
            {/if}
          {/if}
          {#if showCancelButton}
            <Button showIcon={true} on:click={onCancel} btnType={ButtonType.cancelModal} text={cancelButtonTitle} />
          {/if}
        </div>
      {/if}
    </div>
  </form>
</div>
