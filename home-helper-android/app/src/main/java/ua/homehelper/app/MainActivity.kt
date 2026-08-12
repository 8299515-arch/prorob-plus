package ua.homehelper.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

data class Category(val icon: String, val title: String)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { HomeHelperApp() }
    }
}

@Composable
fun HomeHelperApp() {
    var selected by remember { mutableIntStateOf(0) }
    val categories = listOf(
        Category("🔧", "Ремонт"), Category("🚿", "Сантехніка"),
        Category("⚡", "Електрика"), Category("🧹", "Прибирання"),
        Category("🚚", "Перевезення"), Category("❄️", "Кондиціонери"),
        Category("🪚", "Будівельні роботи"), Category("🛠️", "Інше")
    )
    MaterialTheme {
        Scaffold(bottomBar = {
            NavigationBar {
                NavigationBarItem(selected == 0, { selected = 0 }, icon = { Text("🏠") }, label = { Text("Головна") })
                NavigationBarItem(selected == 1, { selected = 1 }, icon = { Text("📋") }, label = { Text("Замовлення") })
                NavigationBarItem(selected == 2, { selected = 2 }, icon = { Text("👤") }, label = { Text("Профіль") })
            }
        }) { padding ->
            when (selected) {
                0 -> HomeScreen(categories, Modifier.padding(padding))
                1 -> OrdersScreen(Modifier.padding(padding))
                else -> ProfileScreen(Modifier.padding(padding))
            }
        }
    }
}

@Composable
fun HomeScreen(categories: List<Category>, modifier: Modifier = Modifier) {
    Column(modifier.fillMaxSize().padding(20.dp)) {
        Text("🏠 Домашній помічник", style = MaterialTheme.typography.headlineMedium, fontWeight = FontWeight.Bold)
        Spacer(Modifier.height(8.dp))
        Text("Чим допомогти сьогодні?", style = MaterialTheme.typography.titleMedium)
        Spacer(Modifier.height(16.dp))
        Button(onClick = {}, modifier = Modifier.fillMaxWidth().height(56.dp)) { Text("🤖 Запитати AI-помічника") }
        Spacer(Modifier.height(20.dp))
        Text("Послуги", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
        Spacer(Modifier.height(10.dp))
        LazyVerticalGrid(columns = GridCells.Fixed(2), verticalArrangement = Arrangement.spacedBy(12.dp), horizontalArrangement = Arrangement.spacedBy(12.dp), modifier = Modifier.fillMaxSize()) {
            items(categories) { c ->
                Card(onClick = {}, modifier = Modifier.height(115.dp)) {
                    Column(Modifier.fillMaxSize().padding(12.dp), verticalArrangement = Arrangement.Center, horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(c.icon, style = MaterialTheme.typography.headlineMedium)
                        Spacer(Modifier.height(6.dp)); Text(c.title, fontWeight = FontWeight.SemiBold)
                    }
                }
            }
        }
    }
}

@Composable
fun OrdersScreen(modifier: Modifier = Modifier) {
    Column(modifier.fillMaxSize().padding(20.dp)) {
        Text("📋 Мої замовлення", style = MaterialTheme.typography.headlineMedium, fontWeight = FontWeight.Bold)
        Spacer(Modifier.height(20.dp))
        Card(Modifier.fillMaxWidth()) { Column(Modifier.padding(16.dp)) {
            Text("Поки що замовлень немає", fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(6.dp)); Text("Створіть першу заявку, щоб знайти майстра.")
        }}
    }
}

@Composable
fun ProfileScreen(modifier: Modifier = Modifier) {
    Column(modifier.fillMaxSize().padding(20.dp)) {
        Text("👤 Профіль", style = MaterialTheme.typography.headlineMedium, fontWeight = FontWeight.Bold)
        Spacer(Modifier.height(20.dp)); Text("Гість", style = MaterialTheme.typography.titleLarge)
        Spacer(Modifier.height(8.dp)); Text("Увійдіть або зареєструйтесь, щоб замовляти послуги.")
        Spacer(Modifier.height(20.dp)); Button(onClick = {}, modifier = Modifier.fillMaxWidth()) { Text("Увійти") }
    }
}
