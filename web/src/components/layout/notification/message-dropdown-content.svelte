<script>
  import QuickSearch from 'src/components/ui/input/quick-search';
  import MessageItem from './message-item.svelte';
  import { T } from 'src/lib/locale';
  import { fromEvent, BehaviorSubject } from 'rxjs';
  import { switchMap, tap } from 'rxjs/operators';
  import { NotificationStore } from 'src/store/notification';
  import { SObject } from 'src/lib/sobject';
  import { Mark } from 'src/lib/mark';
  // import HumanOrOrgStore from 'src/modules/sys/user/store';
  import { findAvatar } from './helper';

  import SubmitIcon from 'src/icons/submit24x24.svelte';
  import CancelSubmitIcon from 'src/icons/cancel-submit24x24.svelte';

  import AssignIcon from 'src/icons/assign24x24.svelte';
  import UnAssignIcon from 'src/icons/un-assign24x24.svelte';

  import HoldIcon from 'src/icons/hold24x24.svelte';
  import UnHoldIcon from 'src/icons/un-hold24x24.svelte';

  import Reminder1Icon from 'src/icons/reminder124x24.svelte';
  import Reminder2Icon from 'src/icons/reminder224x24.svelte';

  import NotifyIcon from 'src/icons/notify24x24.svelte';
  import SearchIcon from 'src/icons/search.svelte';

  export let data;
  export let type;

  let filteredData = [],
    groupFilteredData = [];
  let searchProgress$ = new BehaviorSubject(false);
  let textSearch = '';
  let showSearch = false;

  let iconsTab = [
    { icon: SubmitIcon, messageTypes: ['SUBMIT', 'APPROVE'], show: true, count: 0 },

    { icon: AssignIcon, messageTypes: ['ASSIGN', 'HOLD'], show: false, count: 0 },

    { icon: Reminder1Icon, messageTypes: ['REMINDER1'], show: undefined, count: 0 },
    { icon: Reminder2Icon, messageTypes: ['REMINDER2'], show: undefined, count: 0 },

    { icon: NotifyIcon, messageTypes: ['UPDATE', 'COMPLETE'], show: undefined, count: 0 },
  ];

  $: {
    filteredData = data;
  }

  const getCounter = (messageTypes) => {
    return filteredData.filter((it) => !it.isRead && messageTypes.includes(it.messageType)).length;
  };

  const applyTab = (foundMessageType) => {
    let firstTime = false;
    for (let i = 0; i < iconsTab.length; i++) {
      iconsTab[i].show = undefined;

      const index = foundMessageType.findIndex((it) => iconsTab[i].messageTypes.includes(it.messageType));

      if (index >= 0) {
        if (!firstTime) {
          iconsTab[i].show = true;

          onClickTab({
            messageTypes: iconsTab[i].messageTypes,
            show: undefined,
          });
        } else {
          iconsTab[i].show = false;
        }
        firstTime = true;
        iconsTab[i].count = getCounter(iconsTab[i].messageTypes);
      }
    }

    iconsTab = [...iconsTab];
  };

  $: {
    groupFilteredData = filteredData;
    let messageTypeAndIsCancel = filteredData.map((it) => {
      return {
        index: it.messageType,
        messageType: it.messageType,
      };
    });

    messageTypeAndIsCancel = SObject.distinctArrayObject(messageTypeAndIsCancel);
    messageTypeAndIsCancel = messageTypeAndIsCancel.filter((it) => it.messageType !== null);

    applyTab(messageTypeAndIsCancel);
  }

  const useInputAction = {
    register(component, param) {
      fromEvent(component, 'input')
        .pipe(
          tap((event) => {
            searchProgress$.next(true);
            textSearch = event.target.value;
          }),
          switchMap((_) => doFilter(textSearch)),
        )
        .subscribe((res) => {
          filteredData = res.data.map((it) => SObject.convertFieldsToCamelCase(it));

          const fromHumanIds = filteredData.map((it) => it.fromHumanId);
          const distinctFromHumanIds = new Set(fromHumanIds);

          filteredData.map((it) => {
            it.title = Mark.mark(it.title, textSearch);
            return it;
          });

          if (distinctFromHumanIds.size > 0) {
            // HumanOrOrgStore.findAvatars([...distinctFromHumanIds].join(',')).subscribe((res) => {
            //   filteredData = filteredData.map((it) => {
            //     it.fromHumanAvatar = findAvatar(res.data, it.fromHumanId);
            //     return it;
            //   });
            // });
          }

          textSearch = '';
          searchProgress$.next(false);
        });
    },
  };

  const doFilter = (value) => {
    return NotificationStore.findNotifications(type, value);
  };

  const onClickTab = (event) => {
    if (event.show) {
      return;
    }

    const index = iconsTab.findIndex((it) => it.messageTypes === event.messageTypes);

    iconsTab.map((it, idx) => {
      it.show = index === idx ? true : it.show === undefined ? undefined : false;

      return it;
    });

    iconsTab = [...iconsTab];

    if (index >= 0) {
      groupFilteredData = filteredData.filter((it) => {
        return iconsTab[index].messageTypes.includes(it.messageType);
      });
    }
  };

  const onClickToggleSearch = () => {
    showSearch = !showSearch;
  };
</script>

<div style="overflow: auto; width: 100%; height: 100%;" class="default-padding">
  <div style="display: flex; align-content: space-between;">
    <div class="bold-text" style="width: 100%;">{T('TASK.LABEL.' + type)}</div>
    <div style="text-align: right; cursor: pointer" on:click={onClickToggleSearch}>
      {#if showSearch}
        <i class="fa fa-chevron-up" />
      {:else}
        <SearchIcon />
      {/if}
    </div>
  </div>
  {#if showSearch}
    <QuickSearch loading$={searchProgress$} action={useInputAction} placeholder={T('SYS.LABEL.FILTER')} />
  {/if}
  <div style="display: flex; margin-top: 10px; justify-content: center; align-content: center;">
    {#each iconsTab as icon}
      {#if icon.show !== undefined}
        <div on:click={() => onClickTab(icon)} style="position: relative; margin-left: 10px; margin-right: 10px;">
          <svelte:component
            this={icon.icon}
            className="large-svg-icon {icon.show === false ? 'svg-disabled cursor-pointer' : ''}" />
          {#if icon.count > 0}
            <div class="badge {icon.show === false ? 'disabled-badge' : ''}">{icon.count}</div>
          {/if}
        </div>
      {/if}
    {/each}
  </div>
  {#each groupFilteredData as row}
    <MessageItem on:click notification={row} />
  {/each}
</div>
