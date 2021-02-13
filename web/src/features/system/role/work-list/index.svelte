<script>
  import { createEventDispatcher, onDestroy } from 'svelte';
  import { Observable } from 'rxjs';
  import { fromPromise } from 'rxjs/internal-compatibility';
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
  export let callFrom;

  callFrom;
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
        switchMap((_) => fromPromise(view.getOneById(selectedId))),
      )
      .subscribe((res) => {
        if (window.isSmartPhone) {
          isDetailPage$.next(true);
          setTimeout(() => {
            view.selectedData$.next(res);

            detailTitle = getViewTitleFromMenuPath(menuPath) + ' - ' + res.name;
            view.loading$.next(false);
            selectedId = undefined;
          });
        } else {
          view.selectedData$.next(res);
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
