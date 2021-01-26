<script>
  import { createEventDispatcher } from 'svelte';
  import { T } from 'src/lib/locale';
  import { AppStore } from 'src/store/app';
  import RouterLink from 'src/components/ui/router-link/index.svelte';
  import { SettingsStore } from 'src/store/settings';
  import { Dropdown } from 'src/lib/dropdown';
  import { MenuStore } from 'src/features/system/menu/store';
  import { routerLinkStore } from 'src/components/ui/router-link/store';
  import { LoginInfo } from 'src/store/login-info';

  const { departmentId$ } = LoginInfo;

  const { isDetailPage$ } = AppStore;
  const { menu$ } = MenuStore;

  const dispatch = createEventDispatcher();

  let routerLink;
  let visibleCountItem = 0;
  let mainNavBarRef;

  let containerWidth;

  $: if ($menu$) {
    containerWidth = window['$']('#mainNavBarWrapperId') && window['$']('#mainNavBarWrapperId').width();
    if ($menu$.length > 0) {
      routerLinkStore.currentComponentUri$.next(`features/${$menu$[0].path}/index.svelte`);
    }
  }

  const onNavigate = (event) => {
    Dropdown.hide('mainNavBarMoreId');
    saveSettings(event.detail.path);
    saveHistorySettings($departmentId$, event.detail.menuId);
    isDetailPage$.next(false);
  };

  const saveSettings = (menuPath) => {
    SettingsStore.saveUserSettings(
      {
        keys: ['menuPath'],
        values: [menuPath.startsWith('/') ? menuPath.slice(1) : menuPath],
      },
      false,
    );
  };

  const saveHistorySettings = (depId, menuId) => {
    MenuStore.saveOrUpdateMenuHistory(depId, menuId).subscribe();
  };

  const onMouseoverMore = () => {
    Dropdown.show('mainNavBarMoreId');
  };

  const onMouseoutMore = () => {
    Dropdown.hide('mainNavBarMoreId');
  };
</script>

<div class="nav" id="mainNavBarWrapperId">
  <div bind:this={mainNavBarRef} id="mainNavBarId" style="display: flex;">
    {#if $menu$}
      {#each $menu$ as row}
        {#if window['$']('#mainNavBarId').width() < containerWidth - 300}
          <RouterLink
            bind:this={routerLink}
            menuId={row.id}
            menuName={row.name}
            on:navigate={onNavigate}
            __path={'/' + row.path.replace('/', '--')}
            activeClass="active" />
        {:else if window['$']('#mainNavBarId').width() >= containerWidth - 300 && !document.querySelector('#mainNavBarMoreId')}
          <div class="more nav-item" on:mouseover|stopPropagation={onMouseoverMore} on:mouseout={onMouseoutMore}>
            <span>{T('SYS.LABEL.MORE')} &nbsp;&nbsp;</span>
            <i class="dropdown-mark-icon fa fa-angle-down" />

            <div id="mainNavBarMoreId" class="right-dropdown-content">
              {#each $menu$ as row}
                {#if !document.querySelector('#' + row.path.replace('/', '--'))}
                  <RouterLink
                    bind:this={routerLink}
                    menuId={row.id}
                    menuName={row.name}
                    on:navigate={onNavigate}
                    __path={'/' + row.path.replace('/', '--')}
                    activeClass="active" />
                {/if}
              {/each}
            </div>
          </div>
        {/if}
      {/each}
    {/if}
  </div>
</div>
