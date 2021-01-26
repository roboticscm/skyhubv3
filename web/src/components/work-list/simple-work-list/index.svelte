<script>
  import { onMount, onDestroy } from 'svelte';
  import SelectableTable from 'src/components/ui/selectable-table';
  import { NotifyListener } from 'src/store/notify-listener';
  import Pagination from 'src/components/ui/pagination';
  import QuickSearch from 'src/components/ui/input/quick-search';
  import { take, skip } from 'rxjs/operators';

  export let view;
  export let menuPath;

  const columns = view.customWorkListColumns ? view.customWorkListColumns() : view.createWorkListColumns();
  const { dataList$, fullCount$ } = view;

  let tableRef;
  let pageRef;
  let needSelectIdSub, needHighlightIdSub, selectDataSub, notifyListenerSub;

  // =========================SUBSCRIPTION===========================
  const subscription = () => {
    notifyListenerSub = NotifyListener.payload$.subscribe((notifyListener) => {
      if (notifyListener && notifyListener.table === view.tableName) {
        reload();
        if (view.selectedData$.value && view.selectedData$.value.id) {
          view.dataList$.pipe(skip(1), take(1)).subscribe((list) => {
            if (view.selectedData$.value !== null) {
              view.needHighlightId$.next(view.selectedData$.value.id);
            }
          });
        }
      }
    });

    needSelectIdSub = view.needSelectId$.subscribe((id) => {
      if (tableRef && id) {
        tableRef.selectRowById(id);
        view.dataList$.pipe(skip(1), take(1)).subscribe((list) => {
          setTimeout(() => {
            tableRef && tableRef.selectRowById(id);
          }, 200);
        });
      }
    });

    needHighlightIdSub = view.needHighlightId$.subscribe((id) => {
      if (tableRef && id) {
        tableRef.highlightRowById(id);
        view.dataList$.pipe(skip(1), take(1)).subscribe((list) => {
          setTimeout(() => {
            tableRef && tableRef.highlightRowById(id);
          }, 200);
        });
      }
    });

    selectDataSub = view.selectedData$.subscribe((data) => {
      if (data && tableRef) {
        tableRef.highlightRowById(data.id);
      } else if (tableRef) {
        tableRef && tableRef.unSelectAll();
      }
    });
  };
  // =========================//SUBSCRIPTION===========================

  // =========================HELPER FUNCTION===========================
  const reload = () => {
    if (view.customFindList) {
      view.customFindList();
    } else {
      view.findSimpleList();
    }

    tableRef && tableRef.unSelectAll();
    view.checkDeletedRecord(false);
  };

  // =========================HELPER FUNCTION===========================

  // =========================EVENT HANDLE===========================
  const onLoadPage = (event) => {
    view.pageSize = event.detail.pageSize;
    view.page = event.detail.page;
    reload();
  };

  const onPaginationInit = (event) => {
    view.pageSize = event.detail;
  };
  // =========================//EVENT HANDLE===========================

  // =========================HOOK===========================
  onMount(() => {
    subscription();
    pageRef.loadSettings().then(() => {
      reload();
    });
  });

  onDestroy(() => {
    notifyListenerSub && notifyListenerSub.unsubscribe();
    needSelectIdSub && needSelectIdSub.unsubscribe();
    needHighlightIdSub && needHighlightIdSub.unsubscribe();
    selectDataSub && selectDataSub.unsubscribe();
  });
  // =========================//HOOK===========================
</script>

<div style="margin-top: 1px;">
  <Pagination
    {menuPath}
    totalRecords={$fullCount$}
    smallSize={true}
    on:loadPage={onLoadPage}
    on:init={onPaginationInit}
    bind:this={pageRef} />
</div>

<div style="height: calc(100% - 20px);">
  <SelectableTable
    startRowCount={(view.page - 1) * view.pageSize + 1}
    bind:this={tableRef}
    on:selection
    {columns}
    {menuPath}
    showRowNumber={true}
    data={$dataList$}
    id={`${view.getViewName()}_TableId`}>
    <span style="display: flex; padding-bottom: 6px;" slot="header" let:filter>
      <div style="width: 100%;">
        <QuickSearch on:input={(e) => filter(e.target.value)} />
      </div>
    </span>
  </SelectableTable>
</div>
