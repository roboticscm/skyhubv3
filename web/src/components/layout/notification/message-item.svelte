<script>
  import { T } from 'src/lib/locale';
  import { SDate } from 'src/lib/sdate';
  import { NotifyType } from 'src/store/notification';
  import { getViewTitleFromMenuPath } from 'src/lib/url-util';
  import { createEventDispatcher } from 'svelte';
  import { StringUtil } from 'src/lib/string-util';
  import SubmitIcon from 'src/icons/submit24x24.svelte';
  import CancelSubmitIcon from 'src/icons/cancel-submit24x24.svelte';

  import AssignIcon from 'src/icons/assign24x24.svelte';
  import UnAssignIcon from 'src/icons/un-assign24x24.svelte';

  import HoldIcon from 'src/icons/hold24x24.svelte';
  import UnHoldIcon from 'src/icons/un-hold24x24.svelte';

  import Reminder1 from 'src/icons/reminder124x24.svelte';
  import Reminder2 from 'src/icons/reminder224x24.svelte';
  import UpdateIcon from 'src/icons/update24x24.svelte';
  import CompleteIcon from 'src/icons/complete.svelte';
  import UnCompleteIcon from 'src/icons/un-complete.svelte';
  const dispatch = createEventDispatcher();

  export let notification;

  $: isOld = notification.type === NotifyType.Functional ? notification.isFinished : notification.isRead;

  const onClick = () => {
    dispatch('click', notification);
  };
</script>

<div
  on:click={onClick}
  class="{isOld ? 'notify-dropdown-item-old' : ''}
  {notification.isCancel ? 'notify-dropdown-item-cancel' : ''} notify-dropdown-item default-rounded-border
  default-padding"
  style="margin-top: 6px;">

  <div class="notify-dropdown-item__header">
    <div title={notification.fromHumanFullName} class="notify-dropdown-item__header__avatar">
      {#if notification.fromHumanAvatar}
        <img class="notify-dropdown-item__header__avatar__image" src={notification.fromHumanAvatar} alt="" />
      {:else if notification.fromHumanFullName}
        <div class="notify-dropdown-item__header__avatar__no">
          {StringUtil.getAvatar(notification.fromHumanFullName)}
        </div>
      {:else}
        <i class="notify-dropdown-item__header__avatar__no fa fa-desktop" />
      {/if}
    </div>

    <div class="notify-dropdown-item__header__text">
      <div>
        {notification.departmentName || T('SYS.MSG.NO_DEPARTMENT')}\{getViewTitleFromMenuPath(notification.menuPath)}
      </div>

      <div>{SDate.convertMillisecondToDateTimeString(notification.createdDate)}</div>

    </div>
  </div>

  <div
    class="notify-dropdown-item__content"
    title={StringUtil.removeHtmlTag(StringUtil.replaceAll(notification.title, '<br>', '\n'))
      .replace('<span class="italic-text">', '')
      .replace('</span>', '')}>
    <div class="notify-dropdown-item__content__image">
      {#if notification.messageType === 'SUBMIT'}
        {#if notification.isCancel}
          <CancelSubmitIcon className="large-svg-icon {isOld ? 'svg-disabled' : ''}" />
        {:else}
          <SubmitIcon className="large-svg-icon {isOld ? 'svg-disabled' : ''}" />
        {/if}
      {:else if notification.messageType === 'ASSIGN'}
        {#if notification.isCancel}
          <UnAssignIcon className="large-svg-icon {isOld ? 'svg-disabled' : ''}" />
        {:else}
          <AssignIcon className="large-svg-icon {isOld ? 'svg-disabled' : ''}" />
        {/if}
      {:else if notification.messageType === 'HOLD'}
        {#if notification.isCancel}
          <UnHoldIcon className="large-svg-icon {isOld ? 'svg-disabled' : ''}" />
        {:else}
          <HoldIcon className="large-svg-icon {isOld ? 'svg-disabled' : ''}" />
        {/if}
      {:else if notification.messageType === 'COMPLETE'}
        {#if notification.isCancel}
          <UnCompleteIcon className="large-svg-icon {isOld ? 'svg-disabled' : ''}" />
        {:else}
          <CompleteIcon className="large-svg-icon {isOld ? 'svg-disabled' : ''}" />
        {/if}
      {:else if notification.messageType === 'REMINDER1'}
        <Reminder1 className="large-svg-icon {isOld ? 'svg-disabled' : ''}" />
      {:else if notification.messageType === 'REMINDER2'}
        <Reminder2 className="large-svg-icon {isOld ? 'svg-disabled' : ''}" />
      {:else if notification.messageType === 'UPDATE'}
        <UpdateIcon className="large-svg-icon {isOld ? 'svg-disabled' : ''}" />
      {/if}
    </div>
    <div class="notify-dropdown-item__content__text">
      <div class="notify-dropdown-item__content__text__inside">
        {@html notification.title}
      </div>
    </div>
  </div>
</div>
