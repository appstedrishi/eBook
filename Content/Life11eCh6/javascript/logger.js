function log(str) {
  var $log = $('#__log__');
  if (!$log.length) {
    var style = "display:block;background-color:rgba(0,0,0,0.7);color:rgba(0,255,0,1.0);float:left;position:absolute;width:768px;height:300px;top:704px;left:0;";
    $(document.body).append('<div id="__log__" style="' + style + '"></div>');
    $log = $('#__log__');
  }
  $log.prepend("<br/>" + str);
  console.error("=============>", str);
}

__original_console = console;
__original_error = console.error;
__original_log = console.log;

console = {
  msgs: new Array(),

  error: function() {
    var args = ['error: '];
    args.push.apply(args, arguments);
    console.msgs.push(args.join(' '));
    __original_error.apply(__original_console, arguments);
  },

  log: function() {
    var args = ['log: '];
    args.push.apply(args, arguments);
    console.msgs.push(args.join(' '));
    __original_log.apply(__original_console, arguments);
  },

  shift: function() {
    return console.msgs.shift();
  }
};
