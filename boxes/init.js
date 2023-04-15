(function() {
    var oldLog = console.log;
    console.log = function(message) {
        window.location = "console-log://" + encodeURIComponent(message);
        oldLog.apply(console, arguments);
    };
})();

setTimeout(function() {
    window.webkit.messageHandlers.MyApp.postMessage('Hello from JavaScript!');
    console.log('done.');
}, 5000);
