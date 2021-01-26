<script>
  import { T } from 'src/lib/locale';
  import { SettingsStore } from 'src/store/settings';
  import { createEventDispatcher } from 'svelte';
  import { App } from 'src/lib/constants';
  import { SNumber } from 'src/lib/snumber';

  const dispatch = createEventDispatcher();

  export let totalRecords;
  export let smallSize = false;
  export let autoLoad = false;
  export let showDisabledButton = true;
  export let showFirstLastButton = true;
  export let showNextPrev = false;
  export let menuPath;
  export let viewablePage = 7;

  const sizes = [2, 30, 50, 100, 200];
  let pageSize = sizes[0];
  let curPage = 1;
  let fromPage = 1;
  let toPage = 1;

  let totalPages, prevStatus, firstStatus, nextStatus, lastStatus;
  $: {
    totalPages = Math.ceil(totalRecords / pageSize);
    toPage = Math.min(viewablePage, totalPages);
  }
  $: prevStatus = totalPages > 1 && curPage > 1;
  $: firstStatus = curPage > 2;
  $: nextStatus = totalPages > 1 && curPage < totalPages;
  $: lastStatus = curPage < totalPages - 1;

  // const getPages = () => {
  //   const rows = [];
  //   for (let i = 0; i < totalPages - 1; i++) {
  //     rows.push({
  //       id: i + 1,
  //       value: `${i * pageSize + 1} - ${(i + 1) * pageSize}`,
  //     });
  //   }

  //   const i = totalPages - 1;

  //   rows.push({
  //     id: i + 1,
  //     value: `${i * pageSize + 1} - ${i * pageSize +
  //       (totalRecords % pageSize === 0 ? pageSize : totalRecords % pageSize)}`,
  //   });
  //   return rows;
  // };

  export const loadSettings = () => {
    return new Promise((resolve, reject) => {
      SettingsStore.getUserSettings({ elementId: 'pageSizeSelectId', menuPath })
        .then((res) => {
          const filter = res.data.filter((it) => it.key === 'lastPageSize');
          if (filter.length > 0) {
            pageSize = +filter[0].value;
            dispatch('init', pageSize);
          } else {
            pageSize = App.DEFAULT_PAGE_SIZE;
          }
          resolve('ok');
        })
        .catch((error) => {
          reject(error);
        });
    });
  };

  if (autoLoad) {
    loadSettings();
  }

  const onPageSizeChange = (event) => {
    pageSize = +event.target.value;
    const totalPages = Math.ceil(totalRecords / pageSize);
    if (curPage > totalPages) {
      curPage = 1;
    }

    SettingsStore.saveUserSettings({
      menuPath,
      elementId: 'pageSizeSelectId',
      keys: ['lastPageSize'],
      values: [`${pageSize}`],
    });
    requireLoadPage();
  };

  const requireLoadPage = () => {
    dispatch('loadPage', {
      page: curPage,
      pageSize,
    });
  };

  const jumpToPage = (page) => {
    if (page < 1) {
      page = 1;
    } else if (page > totalPages) {
      page = totalPages;
    }
    curPage = page;
    requireLoadPage();
    if (curPage > viewablePage / 2) {
      let to = curPage + Math.floor(viewablePage / 2);
      if (to > totalPages) {
        to = totalPages;
      }
      let from = to - viewablePage + 1;
      if (from < 1) {
        from = 1;
      }
      fromPage = from;
      toPage = to;
    } else {
      fromPage = 1;
      toPage = Math.min(viewablePage, totalPages);
    }
  };

  export const resetPage = () => {
    curPage = 1;
    fromPage = 1;
  };
</script>

{#if totalRecords > 0}
  <span class="pagination" style="white-space: nowrap;">
    {#if totalPages > 1}
      <span style="white-space: nowrap">
        <!--      first button-->
        {#if showFirstLastButton && (firstStatus || showDisabledButton)}
          <button
            type="button"
            title={T('SYS.LABEL.FIRST')}
            disabled={!firstStatus}
            on:click={() => jumpToPage(1)}
            class={smallSize ? 'btn-small-round-flat' : 'btn-round-flat'}>
            <i class="fa fa-angle-double-left" />
          </button>
        {/if}
        <!--      prev button-->
        {#if (prevStatus || showDisabledButton) && showNextPrev}
          <button
            type="button"
            title={T('SYS.LABEL.PREVIOUS')}
            disabled={!prevStatus}
            on:click={() => jumpToPage(curPage - 1)}
            class={smallSize ? 'btn-small-round-flat' : 'btn-round-flat'}>
            <i class="fa fa-angle-left" />
          </button>
        {/if}
        <!-- page-->
        {#each Array(toPage - fromPage + 1) as _, page}
          <button
            type="button"
            title={T('SYS.LABEL.PAGE') + ' ' + SNumber.toLocaleString(page + fromPage)}
            disabled={page + fromPage === curPage}
            on:click={() => jumpToPage(page + fromPage)}
            class={smallSize ? 'btn-small-round-flat' : 'btn-round-flat'}>
            {page + fromPage}
          </button>
        {/each}
        {#if (nextStatus || showDisabledButton) && showNextPrev}
          <button
            type="button"
            title={T('SYS.LABEL.NEXT')}
            disabled={!nextStatus}
            on:click={() => jumpToPage(curPage + 1)}
            class={smallSize ? 'btn-small-round-flat' : 'btn-round-flat'}>
            <i class="fa fa-angle-right" />
          </button>
        {/if}
        <!--     last button-->
        {#if showFirstLastButton && (lastStatus || showDisabledButton)}
          <button
            type="button"
            title={T('SYS.LABEL.LAST')}
            disabled={!lastStatus}
            on:click={() => jumpToPage(totalPages)}
            class={smallSize ? 'btn-small-round-flat' : 'btn-round-flat'}>
            <i class="fa fa-angle-double-right" />
          </button>
        {/if}
      </span>
    {/if}
    <span class={smallSize ? 'small-control-dropdown-wrapper' : 'control-dropdown-wrapper'}>
      <!-- svelte-ignore a11y-no-onchange -->
      <select
        title={T('SYS.LABEL.PAGE_SIZE')}
        on:change={onPageSizeChange}
        bind:value={pageSize}
        class="bg-primary primary {smallSize ? 'small-control-dropdown' : 'control-dropdown'}">
        {#each sizes as size}
          <option value={size}>{size !== -1 ? size : T('SYS.LABEL.ALL')}</option>
        {/each}
      </select>
    </span>
    <span title={T('SYS.LABEL.TOTAL_RECORD') + ': ' + SNumber.toLocaleString(totalRecords)}>
      {#if totalPages < 2}#{SNumber.toLocaleString(totalRecords)}{:else}Σ{SNumber.toLocaleString(totalPages)}{/if}
    </span>
    <slot />
  </span>
{/if}
