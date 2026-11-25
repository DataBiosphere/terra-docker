import tseslint from 'typescript-eslint';

export default tseslint.config(
  { ignores: ['lib/', 'node_modules/', 'terra_jupyterlab_extension/'] },
  ...tseslint.configs.recommended,
  {
    files: ['src/**/*.ts'],
    rules: {
      '@typescript-eslint/no-unused-vars': ['error', { args: 'none' }],
      eqeqeq: 'error',
      'prefer-arrow-callback': 'error'
    }
  }
);
