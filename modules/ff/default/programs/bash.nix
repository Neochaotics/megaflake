{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyControl = [ "ignoreboth" ];
    historySize = 1000;
    historyFileSize = 1000;
    historyIgnore = [
      "clear"
      "exit"
    ];
  };
}
