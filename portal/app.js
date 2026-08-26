(() => {
  const isLocal = location.hostname === "localhost" || location.hostname === "127.0.0.1";
  const protocol = isLocal ? "http:" : "https:";
  const host = location.hostname;

  document.getElementById("sonecaLink").href = `${protocol}//${host}:${isLocal ? "8082" : "10000"}/`;
  document.getElementById("financeiroLink").href = `${protocol}//${host}:${isLocal ? "8081" : "8443"}/`;
  document.getElementById("hostInfo").textContent = isLocal ? "Acesso local" : host;
})();
