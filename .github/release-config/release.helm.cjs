const chartPath = process.env.CHART_PATH;           // e.g. charts/codespace-operator
const chartName = process.env.CHART_NAME;           // e.g. codespace-operator
const tagPrefix = `${chartName}-`;            // -> codespace-operator-v1.2.3
const releaseScope = /(^|,|\s)(codespace|operator|server|charts|chart|helm|oidc|ldap|rbac)(?=,|\s|$)/
const releaseType = /^(docs|chore|build|ci|test|refactor|repo)$/
if (!chartPath || !chartName) {
  throw new Error('CHART_PATH and CHART_NAME must be set');
}

module.exports = {
  branches: ['main'],
  tagFormat: `${tagPrefix}v\${version}`,
  plugins: [
    ['@semantic-release/commit-analyzer', {
      preset: 'conventionalcommits',
      parserOpts: { noteKeywords: ['BREAKING CHANGE', 'BREAKING CHANGES', 'BREAKING'] },
      releaseRules: [
        { breaking: true, scope: releaseScope, release: 'major' },
        { type: 'feat',   scope: releaseScope, release: 'minor' },
        { type: 'fix',    scope: releaseScope, release: 'patch' },
        { type: 'perf',   scope: releaseScope, release: 'patch' },
        { type: 'revert', scope: releaseScope, release: 'patch' },
        { type: releaseType, release: false }
      ]
    }],
    '@semantic-release/release-notes-generator',
    ['@semantic-release/changelog', { changelogFile: `changelogs/CHANGELOG.${chartName}.md` }],
    ['semantic-release-helm3', {
      chartPath,
      registry: 'oci://ghcr.io/codespace-operator/charts',
      onlyUpdateVersion: true
    }],
    ['@semantic-release/git', {
      assets: [`changelogs/CHANGELOG.${chartName}.md`, `${chartPath}/Chart.yaml`],
      message: `chore(release): ${chartName} \${nextRelease.version} [skip ci]\n\n\${nextRelease.notes}`
    }],
    '@semantic-release/github'
  ]
};
