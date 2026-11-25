module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    // Cac type duoc phep trong repo
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'refactor', 'perf', 'test', 'docs', 'chore', 'build', 'ci', 'revert']
    ],
    // Cho phep mo ta tieng Viet co dau / chu hoa
    'subject-case': [0],
    'subject-full-stop': [0, 'never'],
    'header-max-length': [2, 'always', 100],
    'body-max-line-length': [0, 'always'],
    'footer-max-line-length': [0, 'always']
  }
};
