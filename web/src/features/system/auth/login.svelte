<script>
  import { onMount } from 'svelte';
  import SkyhubLogo from 'src/icons/skyhub.svelte';
  import SearchBar from 'src/components/search-bar/index.svelte';
  import QRCode from 'qrcode';
  import { App } from 'src/lib/constants';
  import { of } from 'rxjs';

  const dataList$ = of([]);

  let qrcodeRef;

  onMount(() => {
    QRCode.toCanvas(qrcodeRef, App.NAME, { margin: 0, version: 1 }, function(error) {
      if (error) {
        log.error(error);
      }
    });
  });

  const onRegister = () => {
    log.info('register');
  };
</script>

<svelte:head>
  <title>{`${App.NAME} - ${'SYS.LABEL.LOGIN'.t()}`}</title>
</svelte:head>

<div class="login-wrapper">
  <div class="login-logo {$dataList$.length > 0 ? 'login-logo-margin-top' : ''}">
    <SkyhubLogo />
  </div>
  <div class="login-welcome-text">Welcome to {App.NAME}</div>

  <div class="login-search">
    <SearchBar id="mainSearchBarId" menuPath="intro" />
  </div>
  <div class="login-qrcode">
    <canvas bind:this={qrcodeRef} />
  </div>
  <div style="padding: 10px;">
    <!-- svelte-ignore a11y-invalid-attribute -->
    <a href="#" on:click={onRegister}>{'SYS.LABEL.REGISTER_NOW'.t()}</a>
  </div>
  <div class="news">
    {#if $dataList$ && $dataList$.length > 0}
      {#each $dataList$ as item}
        <!-- <NewsItem news={item} /> -->
      {/each}
    {/if}
  </div>
</div>
