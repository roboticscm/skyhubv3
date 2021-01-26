<script>
  export let icon = '<i class="fa fa-plus"></i>';
  export let title = '';
</script>

<style lang="scss">
  @import '../sass/sass/helpers/variables.scss';
  .floating-button {
    display: flex;
    flex-direction: column;
    justify-content: center;
    position: absolute;
    right: 2px;
    bottom: 2px;
    border-radius: 50%;
    width: 36px;
    height: 36px;
    font-size: 1.5rem;
    outline: none;
    background: green;
    color: white;
    padding-left: 8px;
  }
</style>

<button {title} class="floating-button" on:click>
  {@html icon}
</button>
