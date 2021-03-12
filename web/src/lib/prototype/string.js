String.prototype.insertAt = function (index, string) {   
  return this.substring(0, index) + string + this.substring(index);
}

