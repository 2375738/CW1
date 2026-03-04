import { useState } from "react";
import { useAuth } from "@/app/contexts/AuthContext";
import { useNavigate } from "react-router";
import { Button } from "@/app/components/ui/button";
import { Input } from "@/app/components/ui/input";
import { Label } from "@/app/components/ui/label";
import { Card } from "@/app/components/ui/card";
import { Alert, AlertDescription } from "@/app/components/ui/alert";
import { Users, Loader2, AlertCircle } from "lucide-react";

export default function Login() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setIsLoading(true);

    try {
      await login(email, password);
      // Navigate to home after successful login
      navigate("/");
    } catch (err) {
      setError("Invalid email or password. Try sarah@example.com");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="h-screen w-full flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 p-6">
      <Card className="w-full max-w-md p-8 space-y-6">
        {/* Logo and Title */}
        <div className="text-center space-y-2">
          <div className="w-16 h-16 mx-auto bg-blue-600 rounded-2xl flex items-center justify-center mb-4">
            <Users className="w-10 h-10 text-white" />
          </div>
          <h1 className="text-3xl font-bold text-gray-900">FamilyHub</h1>
          <p className="text-gray-600">Sign in to coordinate with your family</p>
        </div>

        {/* Error Alert */}
        {error && (
          <Alert variant="destructive">
            <AlertCircle className="h-4 w-4" />
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        )}

        {/* Login Form */}
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="email">Email</Label>
            <Input
              id="email"
              type="email"
              placeholder="you@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              disabled={isLoading}
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="password">Password</Label>
            <Input
              id="password"
              type="password"
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              disabled={isLoading}
            />
          </div>

          <Button type="submit" className="w-full" disabled={isLoading}>
            {isLoading ? (
              <>
                <Loader2 className="w-4 h-4 animate-spin" />
                Signing in...
              </>
            ) : (
              "Sign In"
            )}
          </Button>
        </form>

        {/* Demo Credentials */}
        <div className="pt-4 border-t border-gray-200">
          <p className="text-sm text-gray-600 text-center mb-3">Demo Accounts:</p>
          <div className="space-y-2 text-xs text-gray-600">
            <div className="flex justify-between items-center p-2 bg-gray-50 rounded">
              <span>sarah@example.com</span>
              <Button
                type="button"
                variant="ghost"
                size="sm"
                onClick={() => {
                  setEmail("sarah@example.com");
                  setPassword("password");
                }}
                className="h-6 text-xs"
              >
                Use
              </Button>
            </div>
            <div className="flex justify-between items-center p-2 bg-gray-50 rounded">
              <span>mike@example.com</span>
              <Button
                type="button"
                variant="ghost"
                size="sm"
                onClick={() => {
                  setEmail("mike@example.com");
                  setPassword("password");
                }}
                className="h-6 text-xs"
              >
                Use
              </Button>
            </div>
          </div>
          <p className="text-xs text-gray-500 text-center mt-3">
            Any password works for demo accounts
          </p>
        </div>

        {/* Footer */}
        <p className="text-xs text-center text-gray-500">
          FamilyHub keeps your family connected and safe
        </p>
      </Card>
    </div>
  );
}