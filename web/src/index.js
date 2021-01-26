import '@fortawesome/fontawesome-free/css/all.min.css';
import App from './app.svelte';
import '../../sass/sass/index.scss';
import { init } from './init';
import jquery from 'jquery';
import 'jquery-ui';
window.jquery = jquery;
window.jQuery = jquery;
window['$'] = jquery;
import 'src/lib/vendor/jquery.ztree.all';

init().then((res) => {
  new App({
    target: document.body,
  });
});
