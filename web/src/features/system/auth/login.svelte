<script>
  import { onMount } from 'svelte';
  import SkyhubLogo from 'src/icons/skyhub.svelte';
  import SearchBar from 'src/components/search-bar/index.svelte';
  import QRCode from 'qrcode';
  import { App } from 'src/lib/constants';
  import { of } from 'rxjs';
  import { callGRPC, grpcAuthClient } from 'src/lib/grpc';
  import { NotifyListener } from 'src/store/notify-listener';
  import { Authentication } from 'src/lib/authentication';

  const empty = require('google-protobuf/google/protobuf/empty_pb');

  const dataList$ = of([]);

  let qrcodeRef;
  let timer;
  let qrCodeValue;
  onMount(() => {
    NotifyListener.payload$.subscribe((res) => {
      if (res.table === "auth_token" && qrCodeValue && res.data.id === qrCodeValue.replace("[AUTH]", "") && res.data.accessToken && res.data.refreshToken && res.data.accountId && !res.data.authenticated) {
        Authentication.login(res.data.accessToken, res.data.refreshToken, res.data.accountId, res.data.username);
        Authentication.updateAuthenticated(res.data.id);
      }
    });

    generateQrCode();
    timer = setInterval(generateQrCode, App.REFRESH_QR_CODE_TIMEOUT);
    return () => {
      clearInterval(timer);
    };
  });

  const generateQrCode = () => {
    callGRPC(() => {
      const req = new empty.Empty();
      return grpcAuthClient.getQrCodeHandler(req);
    }).then((res) => {
      qrCodeValue = `[AUTH]${res.toObject().qrCode}`;
      QRCode.toCanvas(qrcodeRef, qrCodeValue, { margin: 0, version: 2}, function(error) {
        if (error) {
          log.error(error);
        }
      });
    });
  };

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
    <a href="#" on:click={onRegister}>{T.SYS.LABEL.REGISTER_NOW}</a>
  </div>
  <div class="news">
    {#if $dataList$ && $dataList$.length > 0}
      {#each $dataList$ as item}
        <!-- <NewsItem news={item} /> -->
      {/each}
    {/if}
  </div>
</div>
