<script>
  import { createEventDispatcher, onDestroy } from 'svelte';
  import { forkJoin, Observable } from 'rxjs';
  import { switchMap, tap, filter } from 'rxjs/operators';
  import SimpleWorkList from 'src/components/work-list/simple-work-list';
  import { SObject } from 'src/lib/sobject';
  import { AppStore } from 'src/store/app';
  import { getViewTitleFromMenuPath } from 'src/lib/url-util';
  import MainContent from '../content/index.svelte';

  // Props
  export let view;
  export let menuPath;
  export let store;
  // export let callFrom;

  // Other vars
  let selectedId = undefined;
  const dispatch = createEventDispatcher();
  let selectSub;
  const { isDetailPage$ } = AppStore;
  let detailTitle = '';
  let mainContentRef;

  const doSelect = (ob$) => {
    return ob$
      .pipe(
        filter((_) => selectedId !== undefined),
        tap((_) => view.loading$.next(true)),
        switchMap((_) => forkJoin([view.getOneById(selectedId)])),
      )
      .subscribe((res) => {
        if (window.isSmartPhone) {
          isDetailPage$.next(true);
          setTimeout(() => {
            const selectedData = SObject.convertFieldsToCamelCase(res[0].data[0]);
            view.selectedData$.next(selectedData);

            detailTitle = getViewTitleFromMenuPath(menuPath) + ' - ' + selectedData.name;
            view.loading$.next(false);
            selectedId = undefined;
          });
        } else {
          view.selectedData$.next(SObject.convertFieldsToCamelCase(res[0].data[0]));
          view.loading$.next(false);
          selectedId = undefined;
        }
      });
  };

  const onSelection = (event) => {
    if (event.detail && event.detail.length > 0) {
      selectedId = event.detail[0].id;

      const change$ = new Observable((observer) => {
        observer.next(event);
      });
      selectSub = doSelect(change$);

      dispatch('callback', event.detail[0].id);
    }
  };

  onDestroy(() => {
    if (selectSub) {
      selectSub.unsubscribe();
    }
  });

  const onClickBack = () => {
    isDetailPage$.next(false);
  };
</script>

{#if $isDetailPage$ && window.isSmartPhone}
  <section style="width: 100%;">
    <MainContent backCallback={onClickBack} {detailTitle} {view} {menuPath} {store} bind:this={mainContentRef} />
  </section>
{:else}
  <section class="view-left-main">
    <SimpleWorkList on:selection={onSelection} {view} {menuPath} />
  </section>
{/if}
