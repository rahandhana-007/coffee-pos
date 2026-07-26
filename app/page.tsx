import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Coffee } from "lucide-react";

export default function HomePage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-amber-50 to-orange-100 p-4">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center space-y-4">
          <div className="mx-auto w-16 h-16 bg-amber-600 rounded-full flex items-center justify-center">
            <Coffee className="w-8 h-8 text-white" />
          </div>
          <div>
            <CardTitle className="text-3xl">Coffee POS</CardTitle>
            <CardDescription className="mt-2">
              Sistem Kasir Coffee Shop
            </CardDescription>
          </div>
        </CardHeader>
        <CardContent className="space-y-3">
          <Button asChild className="w-full" size="lg">
            <Link href="/login">Masuk ke Sistem</Link>
          </Button>
          <p className="text-xs text-center text-muted-foreground">
            Versi 0.1.0 · Development
          </p>
        </CardContent>
      </Card>
    </div>
  );
}