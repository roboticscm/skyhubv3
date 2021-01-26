<script>
  import { onMount } from 'svelte';
  import { take } from 'rxjs/operators';
  import { ViewStore } from 'src/store/view';

  import TwoColumnView from 'src/components/ui/two-column-modal-view';
  import WorkList from './work-list/index.svelte';
  import MainContent from './content/index.svelte';
  import ProgressBar from 'src/components/ui/progress-bar';
  import { Store } from './store';

  // Props
  export let showTitle = true;
  export let menuPath;
  export let fullControl;
  export let roleControls;
  export let callFrom = 'Self';
  export let showWorkList = true;

  // Init view
  const view = new ViewStore(menuPath);
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
    view.completeLoading$.pipe(take(1)).subscribe((_) => {
      view.loading$.next(false);
    });
  };
  // ================= //SUBSCRIPTION ========================

  // ================= KOOK ========================
  onMount(() => {
    subscription();
  });

  export const getViewTitle = () => {
    return view.getViewTitle();
  };

  export const getMenuInfo$ = () => {
    return view.menuInfo$;
  };
  // ================= //KOOK ========================
</script>

<ProgressBar loading$={view.loading$} />

<TwoColumnView minLeftPane={!showWorkList} id={'mainLayout' + view.getViewName()} {showTitle} {menuPath}>
  <section style="height: 100%" slot="leftView">
    <WorkList {view} {menuPath} {callFrom} {store} on:callback />
  </section>

  <section style="height: 100%" slot="default">
    {#if !window.isSmartPhone}
      <MainContent {view} {menuPath} {store} on:callback />
    {/if}
  </section>
</TwoColumnView>
