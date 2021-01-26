import { RxHttp } from 'src/lib/rx-http';
import { BaseUrl } from 'src/lib/constants';

export class SearchUtilStore {
  static findSearchFields(menuPath) {
    return RxHttp.get({
      baseUrl: BaseUrl.SYSTEM,
      url: 'search-util',
      params: { menuPath },
    });
  }
}
