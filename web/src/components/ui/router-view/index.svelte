<script>
  import { routerLinkStore } from '../router-link/store';
  import Page404 from 'src/pages/404/index.svelte';
  import PageLoading from 'src/pages/loading/index.svelte';
  import { onMount } from 'svelte';
  import { forkJoin } from 'rxjs';
  import { LoginInfo } from 'src/store/login-info';
  import { RoleControlStore } from 'src/store/role-control';
  import { SearchUtilStore } from 'src/store/search-util';

  let TheComponent;
  const { currentComponentUri$ } = routerLinkStore;
  let menuPath;
  let fullControl = false;
  let roleControls = [];
  let searchFields = [];
  let selectedId;

  const loadComponent = (uri) => {
    if (uri && uri.length > 0) {
      import(`src/${uri}`)
        .then((res) => {
          const { default: com } = res;
          TheComponent = com;
        })
        .catch((error) => {
          TheComponent = Page404;
        });
    }
  };

  const loadRoleControlAndSearchField = (uri) => {
    const roleControl$ = RoleControlStore.findRoleControls(LoginInfo.departmentId$.value, menuPath);

    const searchField$ = SearchUtilStore.findSearchFields(menuPath);

    forkJoin([roleControl$, searchField$]).subscribe((res) => {
      if (res[0].data[0] && res[0].data[0].fullControl) {
        fullControl = true;
      } else {
        roleControls = res[0].data;
      }
      searchFields = res[1].data;
      loadComponent(uri);
    });
  };

  export const show = (path) => {
    currentComponentUri$.next(`features/${path}/index.svelte`);
  };

  export const show404 = () => {
    TheComponent = Page404;
  };

  export const showLoading = () => {
    TheComponent = PageLoading;
  };

  onMount(() => {
    const componentSub = currentComponentUri$.subscribe((res) => {
      if (res) {
        menuPath = res.replace('features/', '').replace('/index.svelte', '');
        LoginInfo.menuPath$.next(menuPath);
        loadRoleControlAndSearchField(res);
        window.history.pushState('', '', `${menuPath.replace('/', '--')}?d=${LoginInfo.departmentId$.value}`);
      }
    });

    // const menuSub = menuStore.selectedData$.subscribe((selectedMenu) => {
    //   if (selectedMenu === undefined) {
    //     window.history.pushState('', '', '/');
    //     showLoading();
    //   } else if (selectedMenu === null) {
    //     window.history.pushState('', '', '/');
    //     show404();
    //   } else {
    //     selectedId = selectedMenu.selectedId;
    //     window.history.pushState('', '', '/' + selectedMenu.path.replace('/', '--'));
    //     show(selectedMenu.path);
    //   }
    // });

    return () => {
      componentSub.unsubscribe();
      // menuSub.unsubscribe();
    };
  });
</script>

<svelte:component this={TheComponent} {menuPath} {fullControl} {roleControls} {selectedId} {searchFields} />
