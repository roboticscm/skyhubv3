<script>
  import { Authentication } from 'src/lib/authentication';
  import { T } from 'src/lib/locale';
  import UserProfilesModal from './components/user-profiles-modal/index.svelte';
  import LogoutIcon from 'src/icons/logout24x24.svelte';
  import ProfilesIcon from 'src/icons/profiles24x24.svelte';
  import { of } from 'rxjs';

  const user$ = of({});

  const qrcode = require('../../../../public/images/qrcode.png').default;

  let userProfilesModalRef;

  const onLogout = (event) => {
    Authentication.logout();
  };

  const showUserProfiles = () => {
    hidePopup();
    userProfilesModalRef.show();
  };
  const showPopup = () => {
    document.querySelector('#userProfilesDropdown').classList.add('show-dropdown');
  };

  const hidePopup = () => {
    document.querySelector('#userProfilesDropdown').classList.remove('show-dropdown');
  };
</script>

<UserProfilesModal bind:this={userProfilesModalRef} />

<div class="user-profiles-wrapper" on:mouseover|stopPropagation={showPopup} on:mouseout={hidePopup}>
  <div class="user-profiles">
    {#if $user$.useFontIcon}
      <span class="user-profiles__icon">
        {@html $user$.fontIcon}
      </span>
    {:else if $user$.iconData}
      <img class="user-profiles__img" src={$user$.iconData} alt="" />
    {:else}
      <span class="user-profiles__icon">
        <i class="fa fa-camera" />
      </span>
    {/if}

    <div id="userProfilesDropdown" class="right-dropdown-content">
      <div class="user-profiles__fullname">{Authentication.getUsername()}</div>
      <div on:click|stopPropagation={showUserProfiles} class="dropdown-item">
        <ProfilesIcon />
        &nbsp; {T('SYS.MENU.USER_PROFILES')}
      </div>
      <div on:click={onLogout} class="dropdown-item">
        <LogoutIcon />
        &nbsp; {T('SYS.MENU.LOGOUT')}
      </div>
    </div>
  </div>
</div>
