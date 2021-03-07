<script>
  import { onMount } from 'svelte';
  import { take } from 'rxjs/operators';
  import { BaseView } from 'src/view/base';

  import TwoColumnView from 'src/components/ui/two-column-modal-view';
  import WorkList from './work-list/index.svelte';
  import MainContent from './content/index.svelte';
  import ProgressBar from 'src/components/ui/progress-bar';
  import { Store } from './store';
  import {App} from 'src/lib/constants';
  // Props
  export let showTitle = true;
  export let menuPath;
  export let fullControl;
  export let roleControls;
  export let callFrom = 'Self';
  export let showWorkList = true;
  export let selectedId;
  export let searchFields;

  selectedId;
  searchFields;

  // Init view
  const view = new BaseView(menuPath);
  export const getMenuInfo$ = () => view.menuInfo$;
  export const getViewTitle = () => view.getViewTitle();

  // view.customFindList = () => {
  //   view.dataList$.next([{
  //     id: 1,
  //     name: 'abc'
  //   }]);
  // }
  // view.customWorkListColumns = () => {
  //   return [{name: 'id', type: 'number', title: 'id1', width: '40%'}, {name: 'name', type: 'text', title: 'name1', width: '60%'}];
  // }

  view.tableName = 'role';
  view.columns = ['id', 'code', 'name', 'sort'];
  view.fullControl = fullControl;
  view.roleControls = roleControls;
  view.loading$.next(true);

  const store = new Store(view);
  store.findOrgTree();

  // ================= SUBSCRIPTION ========================
  const subscription = () => {
    store.completeLoading$.pipe(take(1)).subscribe((_) => {
      view.loading$.next(false);
    });
  };
  // ================= //SUBSCRIPTION ========================

  // ================= HOOK ========================
  onMount(() => {
    subscription();
  });

  // ================= //HOOK ========================
</script>

<ProgressBar loading$={view.loading$} />

<svelte:head>
  <title>{`${App.NAME} - ${view.getViewTitle()}`}</title>
</svelte:head>
<TwoColumnView minLeftPane={!showWorkList} {showTitle} {menuPath}>
  <section style="height: 100%" slot="leftView">
    <WorkList {view} {menuPath} {callFrom} {store} on:callback />
  </section>

  <section style="height: 100%" slot="default">
    {#if !window.isSmartPhone}
      <MainContent {view} {menuPath} {store} backCallback on:callback />
    {/if}
  </section>
</TwoColumnView>
