<script>
  import { onMount } from 'svelte';
  import Split from 'split-grid';
  import { App } from 'src/lib/constants';

  export let headerHeight = '96px';

  const defaultHeaderHeight = headerHeight;

  $: {
    const gridEle = document.querySelector('.layout-container');
    if (gridEle) {
      gridEle.style['grid-template-rows'] = `${headerHeight} ${App.GUTTER_WIDTH}px auto`;
    }
  }

  onMount(async () => {
    Split({
      rowSnapOffset: App.MIN_HEADER_HEIGHT,
      rowGutters: [
        {
          track: 1,
          element: document.querySelector('.layout-horizontal-gutter'),
        },
      ],
      onDrag: (direction, track, gridTemplateStyle) => {
        applyLayout();
      },
      onDragEnd: (direction, track) => {
        const gridEle = document.querySelector('.layout-container');
        let [headerHeight] = gridEle.style['grid-template-rows'].split(' ');

        if (headerHeight && +headerHeight.replace('px', '') > App.MAX_HEADER_HEIGHT) {
          headerHeight = defaultHeaderHeight;
          const gridEle = document.querySelector('.layout-container');
          gridEle.style['grid-template-rows'] = `${headerHeight} ${App.GUTTER_WIDTH}px auto`;
        }
      },
    });

    const gridEle = document.querySelector('.layout-container');
    gridEle.style['grid-template-rows'] = `${defaultHeaderHeight} ${App.GUTTER_WIDTH}px auto`;
    /// TODO
    // appStore.theme$.subscribe((theme) => {
    //   gridEle.style['grid-template-rows'] = `${defaultHeaderHeight} ${App.GUTTER_WIDTH}px auto`;
    // });
  });
</script>

<div class="layout-container">
  <div class="layout-header-wrapper">
    <slot name="header">Header Section</slot>
  </div>
  <div class="layout-horizontal-gutter" />
  <div class="layout-content">
    <slot>Content Section</slot>
  </div>
</div>
