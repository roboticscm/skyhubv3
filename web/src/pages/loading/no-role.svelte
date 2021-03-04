<script>
  import { onMount } from 'svelte';
  import { Authentication } from 'src/lib/authentication';
  import { App } from 'src/lib/constants';
  export let message;

  let counter = 5;
  let timer;
  onMount(() => {
    timer = setInterval(() => {
      if (counter === 0) {
        clearInterval(timer);
        Authentication.logout();
      } else {
        counter--;
      }
    }, 1000);
  });
</script>

<svelte:head>
  <title>{`${App.NAME} - ${'SYS.LABEL.REDIRECTING'.t()}...`}</title>
</svelte:head>

<div class="w-100 h-100 center-box">
  <div>
    <span>
      {@html `${message} (${counter})`}
    </span>
  </div>

</div>
