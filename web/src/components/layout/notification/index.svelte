<script>
  import { AppStore } from 'src/store/app';
  import ChatIcon from 'src/icons/chat.svelte';
  import BellIcon from 'src/icons/bell.svelte';
  import AlertIcon from 'src/icons/alert.svelte';
  import { onMount, onDestroy } from 'svelte';
  import { NotificationStore, NotifyType } from 'src/store/notification';
  import { LoginInfo } from 'src/store/login-info';
  import { Dropdown } from 'src/lib/dropdown';
  import MessageDropdownContent from './message-dropdown-content.svelte';
  import MessageModal from 'src/components/ui/modal/message';
  import { SObject } from 'src/lib/sobject';
  import { getViewTitleFromMenuPath } from 'src/lib/url-util';
  import { SDate } from 'src/lib/sdate';
  import { T } from 'src/lib/locale';
  import { StringUtil } from 'src/lib/string-util';

  import SubmitIcon from 'src/icons/submit24x24.svelte';
  import CancelSubmitIcon from 'src/icons/cancel-submit24x24.svelte';

  import AssignIcon from 'src/icons/assign24x24.svelte';
  import UnAssignIcon from 'src/icons/un-assign24x24.svelte';

  import HoldIcon from 'src/icons/hold24x24.svelte';
  import UnHoldIcon from 'src/icons/un-hold24x24.svelte';

  import Reminder1 from 'src/icons/reminder124x24.svelte';
  import Reminder2 from 'src/icons/reminder224x24.svelte';

  import { findAvatar } from './helper';

  let dataSub;
  let alarm = [];
  let chat = [];
  let functional = [];
  let countChat,
    countFunctional,
    countAlarm = 0;
  let messageToneRef;
  let beforeList = undefined;
  let newestNotificationList = [];
  const messageTone = require('../../../../public/audio/message-tone.ogg').default;
  let firstTimes = true;
  let prevTotalMessagesCount = 0;

  const drawingList = [];

  const reload = () => {
    notificationStore.findNotifications('', '').subscribe((res) => {
      const filteredData = res.data.map((it) => SObject.convertFieldsToCamelCase(it));

      notificationStore.data$.next(filteredData);

      if (filteredData && filteredData.length > 0) {
        const fromHumanIds = filteredData.map((it) => it.fromHumanId);
        const distinctFromHumanIds = new Set(fromHumanIds.filter((it) => it !== null));

        HumanOrOrgStore.findAvatars([...distinctFromHumanIds].join(',')).subscribe((res) => {
          const _filteredData = filteredData.map((it) => {
            it.fromHumanAvatar = findAvatar(res.data, it.fromHumanId);
            return it;
          });

          notificationStore.data$.next(_filteredData);
        });
      }
    });
  };

  const pushToDrawingList = (id) => {
    const index = drawingList.indexOf(id);
    if (index < 0) {
      drawingList.push(id);
      return drawingList.length - 1;
    } else {
      return index;
    }
  };

  const calcPosition = () => {
    const padding = 10;
    const modalWidth = 300;
    const modalHeight = 80;
    const windowWidth = window.innerWidth;
    const windowHeight = window.innerHeight;
    const yNumItems = Math.ceil(windowHeight / (modalHeight + padding)) - 2;

    let count = 0;
    for (const item of newestNotificationList) {
      const index = pushToDrawingList(item.id);
      const col = Math.floor(count / yNumItems);
      item.top = windowHeight - (index + 1 - col * yNumItems) * (modalHeight + padding);
      item.right = col * modalWidth + col * padding + padding;

      count++;
    }
  };

  const registerSubscription = () => {
    const query = gql`
      subscription NotificationSubscription($human_id: bigint!) {
        part_notification(
          limit: 1
          where: { to_human_id: { _eq: $human_id } }
          order_by: { access_date: desc_nulls_last }
        ) {
          access_date
          id
        }
      }
    `;

    const notifyApolloClient$ = apolloClient.subscribe({
      query,
      variables: {
        human_id: getUserId(),
      },
    });
    notifyApolloClient$.subscribe((res) => {
      reload();
    });

    dataSub = notificationStore.data$.subscribe((res) => {
      if (beforeList && !firstTimes) {
        const { addArray } = SObject.getDiffRowObjectArray2(beforeList, res, ['id']);

        newestNotificationList = [...newestNotificationList, ...addArray];
        calcPosition();
      } else {
        newestNotificationList = [];
      }

      if (res.length > 0) {
        beforeList = res;
      }

      alarm = res.filter((it) => it.type === NotifyType.alarm);
      chat = res.filter((it) => it.type === NotifyType.chat);
      functional = res.filter((it) => it.type === NotifyType.functional);

      countAlarm = countUnreadMessage(alarm);
      countChat = countUnreadMessage(chat);
      countFunctional = countUnfinishedMessage(functional);

      const totalMessagesCount = countAlarm + countChat + countFunctional;
      if (totalMessagesCount > 0) {
        if (!firstTimes && totalMessagesCount > prevTotalMessagesCount) {
          messageToneRef && messageToneRef.play();
        }
      }

      prevTotalMessagesCount = totalMessagesCount;
    });
  };

  onMount(() => {
    // registerSubscription();
    setTimeout(() => {
      firstTimes = false;
    }, 5000);
  });

  onDestroy(() => {
    dataSub && dataSub.unsubscribe();
  });

  const countUnreadMessage = (data) => {
    return data.filter((it) => !it.isRead).length;
  };

  const countUnfinishedMessage = (data) => {
    return data.filter((it) => !it.isFinished).length;
  };

  const onMouseover = (id) => {
    document.querySelector('#' + id).style.transform = 'translateY(-5px)';
    if (
      (id === 'chatDropdown' && chat && chat.length > 0) ||
      (id === 'alarmDropdown' && alarm && alarm.length > 0) ||
      (id === 'functionalDropdown' && functional && functional.length > 0)
    ) {
      Dropdown.show(id);
    }
  };

  const onMouseout = (id) => {
    Dropdown.hide(id);
  };

  const showTarget = (notification) => {
    const org = appStore.org$.value;
    if (org) {
      org.departmentId = notification.departmentId;
      org.noLoadMenu = true;
      appStore.org$.next(org);

      setTimeout(() => {
        const menu = menuStore.selectedData$.value;
        menu.path = notification.menuPath;
        menu.selectedId = notification.targetId;
        menuStore.selectedData$.next(menu);

        notificationStore.update(notification.id, true, true).subscribe();
      }, 500);
    }
  };

  const onClickItem = (event, id) => {
    showTarget(event.detail);

    Dropdown.hide(id);
  };

  const onCloseModal = (id) => {
    const index = newestNotificationList.findIndex((item) => item.id === id);
    if (index >= 0) {
      newestNotificationList.splice(index, 1);
      newestNotificationList = [...newestNotificationList];
    }

    const drawingIndex = drawingList.indexOf(id);
    if (drawingIndex >= 0) {
      drawingList.splice(drawingIndex, 1);
    }
  };

  const onClickModal = (notification) => {
    showTarget(notification);
    onCloseModal(notification.id);
  };
</script>

<!-- svelte-ignore a11y-media-has-caption -->
<audio bind:this={messageToneRef}>
  <source src={messageTone} type="audio/ogg" />
</audio>

<!--title={'<span class="bold-text">@: ' + (item.fromHumanFullName || T('SYS.LABEL.SYSTEM')) + '</span>' + '\\' + item.departmentName + '\\' + getViewTitleFromMenuPath(item.menuPath)}-->
<!--content={'<span class="italic-text">' + SDate.convertMillisecondToDateTimeString(item.createdDate) + '</span></br>' + item.title}-->

{#each newestNotificationList as item}
  <MessageModal
    lineThrough={item.isCancel}
    on:click={() => onClickModal(item)}
    on:close={() => onCloseModal(item.id)}
    right={item.right}
    top={item.top}>
    <div slot="title">
      <div class="message-modal__title__header">
        <div class="message-modal__title__header__avatar">
          {#if item.fromHumanAvatar}
            <img class="message-modal__title__header__avatar__image" src={item.fromHumanAvatar} alt="" />
          {:else if item.fromHumanFullName}
            <div class="notify-dropdown-item__title__header__avatar__no">
              {StringUtil.getAvatar(item.fromHumanFullName)}
            </div>
          {:else}
            <i class="message-modal__title__header__avatar__no fa fa-desktop" />
          {/if}
        </div>

        <div class="message-modal__title__header__text">
          <div>{item.departmentName || T('SYS.MSG.NO_DEPARTMENT')}\{getViewTitleFromMenuPath(item.menuPath)}</div>

          <div>{SDate.convertMillisecondToDateTimeString(item.createdDate)}</div>
        </div>
      </div>
    </div>

    <div
      class="message-modal__body__content"
      title={StringUtil.replaceAll(item.title, '<br>', '\n')
        .replace('<span class="italic-text">', '')
        .replace('</span>', '')}>
      <div class="message-modal__body__content__image">
        {#if item.messageType === 'SUBMIT'}
          {#if item.isCancel}
            <item className="large-svg-icon" />
          {:else}
            <SubmitIcon className="large-svg-icon" />
          {/if}
        {:else if item.messageType === 'ASSIGN'}
          {#if item.isCancel}
            <UnAssignIcon className="large-svg-icon" />
          {:else}
            <AssignIcon className="large-svg-icon" />
          {/if}
        {:else if item.messageType === 'HOLD'}
          {#if item.isCancel}
            <UnHoldIcon className="large-svg-icon" />
          {:else}
            <HoldIcon className="large-svg-icon" />
          {/if}
        {:else if item.messageType === 'REMINDER1'}
          <Reminder1 className="large-svg-icon" />
        {:else if item.messageType === 'REMINDER2'}
          <Reminder2 className="large-svg-icon" />
        {/if}
      </div>
      <div class="message-modal__body__content__text">
        <div class="message-modal__body__content__text__inside">
          {@html item.title}
        </div>
      </div>
    </div>
  </MessageModal>
{/each}

<div class="notification">
  <div
    style="position: relative;"
    on:mouseover={() => onMouseover('chatDropdown')}
    on:mouseout={() => onMouseout('chatDropdown')}
    class="notify-icon {countChat === 0 ? 'notify-icon-disabled' : ''}">
    <ChatIcon />
    {#if countChat > 0}
      <div class="badge">{countChat}</div>
    {/if}

    <div id="chatDropdown" class="right-dropdown-content" style="height: 600px;">
      <MessageDropdownContent type={NotifyType.Chat} on:click={(e) => onClickItem(e, 'chatDropdown')} data={chat} />
    </div>
  </div>

  <div
    style="position: relative; margin-left: 20px;"
    on:mouseover={() => onMouseover('functionalDropdown')}
    on:mouseout={() => onMouseout('functionalDropdown')}
    class="notify-icon {countFunctional === 0 ? 'notify-icon-disabled' : ''}">
    <BellIcon />

    {#if countFunctional > 0}
      <div class="badge">{countFunctional}</div>
    {/if}

    <div id="functionalDropdown" class="right-dropdown-content" style="height: 600px;">
      <MessageDropdownContent
        type={NotifyType.Functional}
        on:click={(e) => onClickItem(e, 'functionalDropdown')}
        data={functional} />
    </div>
  </div>

  <div
    style="position: relative; margin-left: 20px;"
    on:mouseover={() => onMouseover('alarmDropdown')}
    on:mouseout={() => onMouseout('alarmDropdown')}
    class="notify-icon {countAlarm === 0 ? 'notify-icon-disabled' : ''}">
    <AlertIcon />
    {#if countAlarm > 0}
      <div class="badge">{countAlarm}</div>
    {/if}
    <div id="alarmDropdown" class="right-dropdown-content" style="height: 600px;">
      <MessageDropdownContent type={NotifyType.Alarm} on:click={(e) => onClickItem(e, 'alarmDropdown')} data={alarm} />
    </div>
  </div>
</div>
