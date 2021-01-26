export class StringUtil {
  static unaccentVietnamese = (str) => {
    str = str.toLowerCase();
    str = str.replace(/à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ/g, 'a');
    str = str.replace(/è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ/g, 'e');
    str = str.replace(/ì|í|ị|ỉ|ĩ/g, 'i');
    str = str.replace(/ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ/g, 'o');
    str = str.replace(/ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ/g, 'u');
    str = str.replace(/ỳ|ý|ỵ|ỷ|ỹ/g, 'y');
    str = str.replace(/đ/g, 'd');
    str = str.replace(/\u0300|\u0301|\u0303|\u0309|\u0323/g, '');
    str = str.replace(/\u02C6|\u0306|\u031B/g, ''); // Â, Ê, Ă, Ơ, Ư
    return str;
  };

  static toSnackCase(str, sep) {
    let ret = '';
    for (let i = 0; i < str.length; i++) {
      let ch = str[i];
      if (ch === ch.toUpperCase()) {
        ret += sep + ch.toLowerCase();
      } else ret += ch;
    }

    return ret;
  }

  static insertAt(source, insString, pos) {
    if (typeof pos == 'undefined' || pos < 0) {
      pos = 0;
    }

    if (pos > source.length) {
      pos = source.length;
    }

    if (typeof insString == 'undefined') {
      insString = '';
    }
    return source.slice(0, pos) + insString + source.slice(pos);
  }

  static isEmpty(source) {
    if (typeof source !== 'string') {
      return source === null || source === undefined;
    }
    return source === null || source === undefined || source.trim().length === 0;
  }

  static replaceAll(source, find, replace) {
    if (StringUtil.isEmpty(source)) {
      return '';
    }
    if (typeof source === 'number' || typeof source === 'boolean') {
      return source;
    }

    return source.replace(new RegExp(find, 'g'), replace);
  }

  static replaceAlls(source, finds, replaces) {
    if (finds.length === 0 || replaces.length === 0 || StringUtil.isEmpty(source) || finds.length !== replaces.length) {
      return source;
    }
    let replaceStr = StringUtil.replaceAll(source, finds[0], replaces[0]);

    for (let i = 1; i < finds.length; i++) {
      replaceStr = StringUtil.replaceAll(replaceStr, finds[i], replaces[i]);
    }

    return replaceStr;
  }

  static toTitleCase(str) {
    if (!str) return str;
    return str.replace(/\w\S*/g, function(txt) {
      return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
    });
  }

  static capitalize = (s) => {
    if (typeof s !== 'string' || s.length === 0) {
      return '';
    }
    return s.charAt(0).toUpperCase() + s.slice(1);
  };

  static toUpperCaseWithUnderscore(str) {
    if (str) {
      return str
        .split(/(?=[A-Z])/)
        .join('_')
        .toUpperCase();
    } else {
      return str;
    }
  }

  static snakeToCamelCase = (str) =>
    str.replace(/([-_][a-z])/g, (group) =>
      group
        .toUpperCase()
        .replace('-', '')
        .replace('_', ''),
    );

  static removeMark = (str) => {
    return str.replace(/<mark>/g, '').replace(/<\/mark>/g, '');
  };

  static removeHtmlTag = (source) => {
    return source.replace(/<\/?[^>]+(>|$)/g, '');
  };

  static removeExtraSpace = (source) => {
    return source;
  };

  static splitHumanName = (fullName) => {
    if (!fullName) {
      return ['', ''];
    }
    fullName = StringUtil.removeExtraSpace(fullName);
    const splits = fullName.split(' ');
    return [splits.slice(0, length - 1).join(' '), splits[splits.length - 1]];
  };

  static toBoolean(str) {
    return JSON.parse(str.toLowerCase());
  }

  static distinctArrayString(array) {
    return [...new Set(array)];
  }

  static formatFTSParam(value) {
    if (StringUtil.isEmpty(value)) {
      return '';
    }

    if (value.startsWith('"')) {
      return StringUtil.replaceAll(value, ' ', '<->');
    }

    if (value.startsWith('`')) {
      return StringUtil.replaceAll(value, '`', '');
    }

    return StringUtil.unaccentVietnamese(
      StringUtil.replaceAll(StringUtil.replaceAll(value, ' ', ':*&') + ':*', '#', ''),
    );
  }

  static formatSearchParam(value) {
    if (StringUtil.isEmpty(value)) {
      return '';
    }

    return StringUtil.replaceAll(StringUtil.unaccentVietnamese(value), "'", '');
  }

  static formatExactlySearchParam(value) {
    if (StringUtil.isEmpty(value)) {
      return '';
    }

    return StringUtil.replaceAll(StringUtil.replaceAll(StringUtil.unaccentVietnamese(value), "'", ''), '#', '');
  }

  static getFirstWord = (source) => {
    if (StringUtil.isEmpty(source)) {
      return source;
    }

    const split = source.split(' ');
    if (split.length > 0) {
      return split[0];
    }

    return source;
  };

  static getAvatar = (name) => {
    if (StringUtil.isEmpty(name)) {
      return name;
    }

    const split = name.split(' ');
    if (split.length > 1) {
      return (split[0].substring(0, 1) + split[split.length - 1].substring(0, 1)).toUpperCase();
    } else {
      return split[0].substring(0, 1).toUpperCase();
    }
  };

  static countDiv(source) {
    return (source.match(/<div>/g) || []).length;
  }

  static markStringSearch = (source, searchs, removeAccent = true) => {
    if (!source || !searchs) {
      return source;
    }
    let newSource;
    if (removeAccent) {
      newSource = StringUtil.unaccentVietnamese(source);
      searchs = StringUtil.unaccentVietnamese(searchs);
    } else {
      newSource = source;
    }

    for (let search of searchs.split('|')) {
      const re = new RegExp(search, 'gi');
      const indices = new Array();
      let current;
      while ((current = re.exec(newSource)) != null) {
        indices.push(current.index);
      }

      for (let i = indices.length - 1; i >= 0; i--) {
        source = StringUtil.insertAt(source, `</mark>`, indices[i] + search.length);
        source = StringUtil.insertAt(source, `<mark>`, indices[i]);
      }
      newSource = source;
    }

    return source;
  };
}
