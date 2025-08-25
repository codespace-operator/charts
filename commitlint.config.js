// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'scope-enum': [2, 'always', [
      'chart',
      'server',
      'operator'
    ]],
    'type-enum': [2, 'always', [
      'feat', 'fix', 'perf', 'refactor', 'docs', 'chore', 'ci', 'build', 'test'
    ]]
  }
};
