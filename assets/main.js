function konamiInit() {
  var keyLog = [];
  var konami = '38,38,40,40,37,39,37,39,66,65';
  $(document).keydown(function(e) {
    console.log(e.keyCode);
    keyLog.push(e.keyCode);
    if (keyLog.toString().indexOf(konami) >= 0) {
      window.location.href = 'https://www.youtube.com/watch?v=S4ifNxLd25M';
    }
  });
}

$(konamiInit);
