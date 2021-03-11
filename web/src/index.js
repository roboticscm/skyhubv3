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
import ServerErrorPage from 'src/pages/error/server';
import 'src/lib/session';

init().then((res) => {
  new App({
    target: document.body,
  });
}).catch((e) => {
  new ServerErrorPage({
    target: document.body,
    props: {
      message: e.message === 'Http response at 400 or 500 level' ? 'Can not connect to Envoy Proxy!' : e.message
    }
  });
});
