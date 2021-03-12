<script>
  import { isDebugMode } from 'src/lib/log';
  import { onMount } from 'svelte';
  import { App } from 'src/lib/constants';

  export let message;

  let counter = 15;
  let timer;
  onMount(() => {
    document.body.removeChild(document.getElementById('loadScreen'));
    document.body.style.cursor = 'auto';
    timer = setInterval(() => {
      if (counter === 0) {
        clearInterval(timer);
        location.reload();
      } else {
        counter--;
      }
    }, 1000);
  });
</script>

<svelte:head>
  <title>{`${process.env.APP_NAME} - Server Error`}</title>
</svelte:head>

<div class="w-100 h-100 center-box">
  <div>
    <div>
      <div>
        {@html 'Unknown error: Server error'}
      </div>
      {#if isDebugMode()}
        <div>
          {@html message}
        </div>
      {/if}
    </div>
    <div>
      <button on:click={() => location.reload()}>Reload {counter}</button>
    </div>
  </div>
 
</div>
