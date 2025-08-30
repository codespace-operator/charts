// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'scope-enum': [2, 'always', [
      'operator',
      'controller',
      'server',
      'ui',
      'api',
      'oidc',
      'ldap',
      'rbac',
      'helm',
      'charts',
      'chart',
      'repo',  // release, repo workflow rules etc
      'ci',     // ci workflow rules etc
      'test'
    ]],
    'type-enum': [2, 'always', [
      'feat', 'fix', 'perf', 'refactor', 'docs', 'chore', 'ci', 'build', 'test'
    ]]
  }
};
