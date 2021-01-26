<script>
  import { MenuStore } from 'src/features/system/menu/store';
  import { AppStore } from 'src/store/app';
  import RouterLink from 'src/components/ui/router-link/index.svelte';
  import { SettingsStore } from 'src/store/settings';
  import { LoginInfo } from 'src/store/login-info';
  import { Dropdown } from 'src/lib/dropdown';

  const { departmentId$ } = LoginInfo;
  const { isDetailPage$ } = AppStore;
  const { menu$ } = MenuStore;

  const onNavigate = (event) => {
    Dropdown.hide('mobileMainNavBarId');
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

  const onMouseover = () => {
    Dropdown.show('mobileMainNavBarId');
  };

  const onMouseout = () => {
    Dropdown.hide('mobileMainNavBarId');
  };
</script>

<div class="nav" id="mainNavBarWrapperId">
  <i class="fa fa-bars" on:mouseover={onMouseover} on:mouseout={onMouseout}>
    <div id="mobileMainNavBarId" class="dropdown-content">
      {#if $menu$ && $menu$.length > 0}
        {#each $menu$ as row}
          <RouterLink
            className="dropdown-item"
            menuId={row.id}
            menuName={row.name}
            on:navigate={onNavigate}
            __path={'/' + row.path.replace('/', '--')}
            activeClass="dropdown-content__selected" />
        {/each}
      {/if}
    </div>
  </i>
</div>
