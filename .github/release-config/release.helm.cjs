const chartPath = process.env.CHART_PATH;           // e.g. charts/codespace-operator
const chartName = process.env.CHART_NAME;           // e.g. codespace-operator
const tagPrefix = `chart-${chartName}-`;            // -> chart-codespace-operator-v1.2.3

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
        { breaking: true, scope: /(^|,|\s)(operator|server)(?=,|\s|$)/, release: 'major' },
        { type: 'feat',   scope: /(^|,|\s)(operator|server)(?=,|\s|$)/, release: 'minor' },
        { type: 'fix',    scope: /(^|,|\s)(operator|server)(?=,|\s|$)/, release: 'patch' },
        { type: 'perf',   scope: /(^|,|\s)(operator|server)(?=,|\s|$)/, release: 'patch' },
        { type: 'revert', scope: /(^|,|\s)(operator|server)(?=,|\s|$)/, release: 'patch' },
        { type: /^(docs|chore|build|ci|test|refactor)$/, release: false }
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
