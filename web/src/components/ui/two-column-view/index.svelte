<script>
  import { onMount, onDestroy } from 'svelte';
  import Split from 'split-grid';
  import { App } from 'src/lib/constants';
  import { SettingsStore } from 'src/store/settings';

  export let showTitle = true;
  export let menuPath;
  export let minLeftPane = false;
  export let defaultLeftWidth = '260px'; // in pixel
  export let leftMaxWidth = 350;

  let contentSplit;

  const createSplit = () => {
    const divElement = document.createElement('div');
    divElement.id = 'leftGutter';
    divElement.classList.add('left-gutter-more');

    document.querySelector('.left-grid-vertical-gutter').appendChild(divElement);
    // loadSettings
    SettingsStore.getUserSettings({
      menuPath,
      elementId: 'leftForm',
    }).then((res) => {
      const found = res.data.find((it) => it.key === 'lastLeftWidth');

      let leftWidth = defaultLeftWidth;
      if (found) {
        leftWidth = found.value;
      }

      let containerEle;
      if (showTitle) {
        containerEle = document.querySelector('.view-container-2-col');
      } else {
        containerEle = document.querySelector('.view-container-2-col-modal');
      }

      containerEle.style['grid-template-columns'] = `${minLeftPane ? 0 : leftWidth} ${App.GUTTER_WIDTH}px auto`;
    });

    return Split({
      columnGutters: [
        {
          track: 1,
          element: document.querySelector('.left-grid-vertical-gutter'),
        },
      ],
      onDragEnd: (direction, track) => {
        let gridEle;
        if (showTitle) {
          gridEle = document.querySelector('.view-container-2-col');
        } else {
          gridEle = document.querySelector('.view-container-2-col-modal');
        }

        let [leftWidth] = gridEle.style['grid-template-columns'].split(' ');

        if (+leftWidth.replace('px', '') > leftMaxWidth) {
          leftWidth = leftMaxWidth + 'px';
        }

        gridEle.style['grid-template-columns'] = `${minLeftPane ? 0 : leftWidth} ${GUTTER_WIDTH}px auto`;

        SettingsStore.saveUserSettings({
          menuPath,
          elementId: 'leftForm',
          keys: ['lastLeftWidth'],
          values: [`${leftWidth}`],
        });
      },
    });
  };

  onMount(() => {
    contentSplit = createSplit();
  });

  onDestroy(() => {
    if (contentSplit) {
      contentSplit.destroy();
    }
  });
</script>

<main class={showTitle ? 'view-container-2-col' : 'view-container-2-col-modal'}>
  <div class="view-left">
    <slot name="leftView" />
  </div>

  <div class="left-grid-vertical-gutter" />
  {#if !window.isSmartPhone}
    <div class="view-content">
      <slot />
    </div>
  {/if}
</main>
