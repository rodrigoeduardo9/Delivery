import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Package, Eye, EyeOff } from 'lucide-react';
import toast from 'react-hot-toast';
import { useAuth } from '../hooks/useAuth';
import { loginSchema, LoginFormData } from '../utils/validators';
import { APP_NAME } from '../config/constants';

export default function LoginPage() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormData) => {
    setIsSubmitting(true);
    try {
      await login(data.email, data.password);
      toast.success('Welcome back!');
      navigate('/dashboard');
    } catch (err: any) {
      toast.error(err.message || 'Login failed');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="flex min-h-screen bg-gradient-to-br from-admin-900 via-admin-800 to-primary-900">
      <div className="flex flex-1 items-center justify-center px-4">
        <div className="w-full max-w-md">
          <div className="mb-8 text-center">
            <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-white/10 backdrop-blur">
              <Package className="h-8 w-8 text-white" />
            </div>
            <h1 className="text-3xl font-bold text-white">{APP_NAME}</h1>
            <p className="mt-2 text-admin-300">Admin Panel</p>
          </div>

          <div className="rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur">
            <h2 className="mb-6 text-xl font-semibold text-white">Sign in</h2>

            <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
              <div>
                <label className="label text-admin-200">Email address</label>
                <input
                  type="email"
                  {...register('email')}
                  className="input bg-white/10 border-white/20 text-white placeholder-admin-400 focus:border-primary-400 focus:ring-primary-400"
                  placeholder="admin@example.com"
                />
                {errors.email && (
                  <p className="mt-1 text-xs text-danger-400">{errors.email.message}</p>
                )}
              </div>

              <div>
                <label className="label text-admin-200">Password</label>
                <div className="relative">
                  <input
                    type={showPassword ? 'text' : 'password'}
                    {...register('password')}
                    className="input bg-white/10 border-white/20 text-white placeholder-admin-400 focus:border-primary-400 focus:ring-primary-400 pr-10"
                    placeholder="Enter your password"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-admin-400 hover:text-admin-200"
                  >
                    {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                </div>
                {errors.password && (
                  <p className="mt-1 text-xs text-danger-400">{errors.password.message}</p>
                )}
              </div>

              <button
                type="submit"
                disabled={isSubmitting}
                className="btn-primary w-full py-3 text-base"
              >
                {isSubmitting ? 'Signing in...' : 'Sign in'}
              </button>
            </form>
          </div>

          <p className="mt-6 text-center text-sm text-admin-500">
            &copy; {new Date().getFullYear()} {APP_NAME}. All rights reserved.
          </p>
        </div>
      </div>
    </div>
  );
}
