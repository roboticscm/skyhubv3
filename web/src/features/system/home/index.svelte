<script>
  import { BaseUrl } from 'src/lib/constants';
  import { NotifyListener } from 'src/store/notify-listener';
  import { AppStore } from 'src/store/app';
  import RouterView from 'src/components/ui/router-view/index.svelte';
  import MainLayout from 'src/components/layout/main-layout';
  import SearchBar from 'src/components/search-bar/index.svelte';
  import BranchDropdown from 'src/components/layout/branch-dropdown/index.svelte';
  import MainNavBar from 'src/components/layout/main-nav-bar/index.svelte';
  import MobileMainNavBar from 'src/components/layout/mobile-main-nav-bar/index.svelte';
  import DepartmentDropdown from 'src/components/layout/department-dropdown/index.svelte';
  import Notification from 'src/components/layout/notification/index.svelte';
  import UserProfiles from 'src/components/layout/user-profiles/index.svelte';
  import WaterMark from 'src/components/layout/water-mark/index.svelte';
  import { SObject } from 'src/lib/sobject'

  const { isDetailPage$ } = AppStore;

  const windowWidth = window.innerWidth;
  const SMALL_SCREEN_WIDTH = 768;

  const events = new EventSource(`${BaseUrl.SYSTEM}/notify`);
  events.onmessage = (res) => {
    const json = JSON.parse(res.data);
    json.data = SObject.convertFieldsToCamelCase(json.data);
    NotifyListener.payload$.next(json);
  };
</script>

{#if windowWidth >= SMALL_SCREEN_WIDTH}
  <MainLayout>
    <section slot="header" class="layout-header layout-header-logged-in">
      <div class="layout-header__top">
        <div class="layout-header__top__left">
          <BranchDropdown />
          <div class="separator" />
          <DepartmentDropdown />
        </div>
        <div class="layout-header__top__center">
          <SearchBar id="mainSearchBarId" menuPath="intro" />
        </div>
        <div class="layout-header__top__right">
          <Notification />
          <UserProfiles />
        </div>
      </div>
      <nav class="layout-header__bottom">
        <MainNavBar />
      </nav>
    </section>

    <WaterMark />
    <div slot="default" style="height: 100%; background: var(--bg-tertiary);">
      <RouterView />
    </div>
  </MainLayout>
{:else}
  <MainLayout headerHeight={$isDetailPage$ ? '50px' : '96px'}>
    <section slot="header" class="{$isDetailPage$ ? 'mobile-header-detail' : 'mobile-header'} ">
      {#if !$isDetailPage$}
        <div class="mobile-header__top">
          <div class="mobile-header__top__logo">
            <!-- <div class="mobile-header__top__logo__mark">
                        <OrgIconMark />
                        </div>
                        <img class="mobile-header__top__logo__img" src={$currentCompany$.iconData} alt="" /> -->
            <BranchDropdown />
            <div class="mobile-separator" />
          </div>
          <div class="mobile-header__top__module">
            <DepartmentDropdown />
          </div>
          <div class="mobile-header__top__avatar">
            <UserProfiles />
          </div>
        </div>

        <div class="mobile-header__bottom">
          <div class="mobile-header__bottom__hamburger-menu">
            <MobileMainNavBar />
          </div>

          <div class="mobile-header__bottom__search">
            <SearchBar id="mainSearchBarId" menuPath="intro" />
          </div>

          <div class="mobile-header__bottom__notify">
            <Notification />
          </div>
        </div>
      {:else}
        <div class="mobile-header-detail__left">
          <div class="mobile-header-detail__left__hamburger-menu">
            <MobileMainNavBar />
          </div>
          <!-- <div class="mobile-header-detail__left__department">{appStore.org.selectedDepartment.departmentName}</div> -->
        </div>

        <div class="mobile-header-detail__right">
          <div class="mobile-header-detail__right__notify">
            <Notification />
          </div>
          <div class="mobile-header-detail__right__avatar">
            <UserProfiles />
          </div>
        </div>
      {/if}
    </section>
    <WaterMark />
    <div slot="default" style="height: 100%; background: var(--bg-tertiary);">
      <RouterView />
    </div>
  </MainLayout>
{/if}
