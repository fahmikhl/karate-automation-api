function fn() {
  var env = karate.env || 'stg';

  var config = {
    env: env,
    baseUrl: 'https://demoqa.com',
    fixtureUser: {
      userName: karate.properties['fixture.username'] || 'kadatest01',
      password: karate.properties['fixture.password'] || 'AirBlender#123'
    }
  };

  if (env === 'dev') {
    config.baseUrl = 'https://demoqa.com';
  }

  karate.configure('connectTimeout', 15000);
  karate.configure('readTimeout', 30000);
  karate.configure('retry', { count: 3, interval: 3000 });

  return config;
}
